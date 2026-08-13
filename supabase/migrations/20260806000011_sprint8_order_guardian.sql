-- Winger Backend V2 - Sprint 8: Order Guardian (Trust & Protection Platform)
-- Migration: 20260806000011_sprint8_order_guardian.sql
-- Description: Extends order_guardian schema with protection_cases, delivery_verifications, dispute_cases, evidence_files, trust_timelines, sla_trackers, risk_signals, fn_evaluate_escrow_release, and fn_expire_protection_windows.

-- 1. Domain Enums
DO $$ BEGIN
    CREATE TYPE order_guardian.enum_protection_status AS ENUM (
        'ACTIVE',
        'DELIVERY_PENDING',
        'DELIVERY_VERIFIED',
        'RELEASE_REQUESTED',
        'DISPUTED',
        'COMPLETED',
        'CLOSED'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE order_guardian.enum_verification_method AS ENUM (
        'CUSTOMER_CONFIRMATION',
        'VENDOR_CONFIRMATION',
        'OTP',
        'QR_CODE',
        'PHOTO_EVIDENCE',
        'AUTO_TIMEOUT'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE order_guardian.enum_dispute_type AS ENUM (
        'DELIVERY_NOT_RECEIVED',
        'WRONG_ITEM',
        'DAMAGED_ITEM',
        'MISSING_ITEMS',
        'SUSPECTED_FRAUD'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- 2. Root Protection Cases Table (`order_guardian.protection_cases`)
DROP TABLE IF EXISTS order_guardian.sla_trackers CASCADE;
DROP TABLE IF EXISTS order_guardian.trust_timelines CASCADE;
DROP TABLE IF EXISTS order_guardian.evidence_files CASCADE;
DROP TABLE IF EXISTS order_guardian.dispute_cases CASCADE;
DROP TABLE IF EXISTS order_guardian.delivery_verifications CASCADE;
DROP TABLE IF EXISTS order_guardian.protection_cases CASCADE;

CREATE TABLE order_guardian.protection_cases (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    order_reference TEXT UNIQUE NOT NULL,
    customer_profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    status order_guardian.enum_protection_status NOT NULL DEFAULT 'ACTIVE',
    escrow_status order_guardian.enum_escrow_status NOT NULL DEFAULT 'LOCKED',
    delivery_status orders.enum_delivery_status NOT NULL DEFAULT 'PENDING',
    protection_window_expires_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW() + INTERVAL '48 hours'),
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    deleted_at TIMESTAMPTZ NULL
);

CREATE INDEX idx_protection_cases_order_ref ON order_guardian.protection_cases(order_reference);
CREATE INDEX idx_protection_cases_customer ON order_guardian.protection_cases(customer_profile_id);
CREATE INDEX idx_protection_cases_status ON order_guardian.protection_cases(status);

-- 3. Delivery Verifications Table (`order_guardian.delivery_verifications`)
CREATE TABLE order_guardian.delivery_verifications (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    case_id UUID NOT NULL REFERENCES order_guardian.protection_cases(id) ON DELETE CASCADE,
    method order_guardian.enum_verification_method NOT NULL DEFAULT 'CUSTOMER_CONFIRMATION',
    verified_by_profile_id UUID NULL REFERENCES public.profiles(id) ON DELETE SET NULL,
    otp_code TEXT NULL,
    qr_code_hash TEXT NULL,
    photo_evidence_url TEXT NULL,
    status TEXT NOT NULL DEFAULT 'VERIFIED', -- 'PENDING', 'VERIFIED', 'REJECTED'
    verified_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_verifications_case ON order_guardian.delivery_verifications(case_id);

-- 4. Dispute Cases Table (`order_guardian.dispute_cases`)
CREATE TABLE order_guardian.dispute_cases (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    case_id UUID NOT NULL REFERENCES order_guardian.protection_cases(id) ON DELETE CASCADE,
    raised_by_profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    dispute_type order_guardian.enum_dispute_type NOT NULL,
    reason TEXT NOT NULL,
    status order_guardian.enum_dispute_status NOT NULL DEFAULT 'OPEN',
    resolution_notes TEXT NULL,
    resolved_by_profile_id UUID NULL REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_dispute_cases_case ON order_guardian.dispute_cases(case_id);
CREATE INDEX idx_dispute_cases_status ON order_guardian.dispute_cases(status);

-- 5. Evidence Files Table (`order_guardian.evidence_files`)
CREATE TABLE order_guardian.evidence_files (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    dispute_id UUID NOT NULL REFERENCES order_guardian.dispute_cases(id) ON DELETE CASCADE,
    uploaded_by_profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    file_url TEXT NOT NULL,
    file_type TEXT NOT NULL DEFAULT 'IMAGE', -- 'IMAGE', 'VIDEO', 'DOCUMENT'
    description TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_evidence_dispute ON order_guardian.evidence_files(dispute_id);

-- 6. Trust Timelines Table (`order_guardian.trust_timelines`) - Immutable Log
CREATE TABLE order_guardian.trust_timelines (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    case_id UUID NOT NULL REFERENCES order_guardian.protection_cases(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT NULL,
    actor_profile_id UUID NULL REFERENCES public.profiles(id) ON DELETE SET NULL,
    metadata JSONB NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_trust_timelines_case ON order_guardian.trust_timelines(case_id);

-- 7. SLA Trackers Table (`order_guardian.sla_trackers`)
CREATE TABLE order_guardian.sla_trackers (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    case_id UUID NOT NULL REFERENCES order_guardian.protection_cases(id) ON DELETE CASCADE,
    sla_type TEXT NOT NULL, -- 'VENDOR_RESPONSE', 'CUSTOMER_CONFIRM', 'DISPUTE_RESOLUTION'
    deadline_at TIMESTAMPTZ NOT NULL,
    is_breached BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_sla_trackers_case ON order_guardian.sla_trackers(case_id);

-- 8. Risk Signals Table (`order_guardian.risk_signals`)
CREATE TABLE order_guardian.risk_signals (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    case_id UUID NOT NULL REFERENCES order_guardian.protection_cases(id) ON DELETE CASCADE,
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    signal_type TEXT NOT NULL, -- 'REPEAT_DISPUTES', 'DELIVERY_FAILURE_SPIKE', 'FALSE_CLAIM'
    risk_score INTEGER NOT NULL CHECK (risk_score BETWEEN 1 AND 100),
    details JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_risk_signals_case ON order_guardian.risk_signals(case_id);

-- Triggers for updated_at
CREATE TRIGGER trg_prot_cases_updated_at BEFORE UPDATE ON order_guardian.protection_cases FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();
CREATE TRIGGER trg_dispute_cases_updated_at BEFORE UPDATE ON order_guardian.dispute_cases FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();

-- 9. STORED PROCEDURES & RELEASE ENGINE

-- 9.1 Evaluate Escrow Release Procedure (Publishes EscrowReleaseRequested Event)
CREATE OR REPLACE FUNCTION order_guardian.fn_evaluate_escrow_release(p_case_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_case RECORD;
    v_open_disputes INTEGER := 0;
BEGIN
    SELECT * INTO v_case FROM order_guardian.protection_cases WHERE id = p_case_id FOR UPDATE;

    IF v_case.id IS NULL THEN
        RAISE EXCEPTION 'Protection case % not found', p_case_id USING ERRCODE = 'P0002';
    END IF;

    -- Check for open disputes
    SELECT COUNT(*) INTO v_open_disputes FROM order_guardian.dispute_cases WHERE case_id = p_case_id AND status IN ('OPEN', 'UNDER_REVIEW');

    IF v_open_disputes > 0 THEN
        RETURN jsonb_build_object('eligible', false, 'reason', 'Active dispute in progress');
    END IF;

    IF v_case.status NOT IN ('DELIVERY_VERIFIED', 'ACTIVE') THEN
        RETURN jsonb_build_object('eligible', false, 'reason', 'Case is not in verified or active status');
    END IF;

    -- Update Case Status
    UPDATE order_guardian.protection_cases
    SET status = 'RELEASE_REQUESTED',
        updated_at = TIMEZONE('utc', NOW())
    WHERE id = p_case_id;

    -- Log Trust Timeline
    INSERT INTO order_guardian.trust_timelines (case_id, event_type, title, description)
    VALUES (p_case_id, 'ESCROW_RELEASE_REQUESTED', 'Escrow Release Requested', 'Release conditions met. Event published to Financial Core.');

    -- Publish EscrowReleaseRequested Event to Outbox (Financial Core will execute accounting)
    PERFORM public.fn_publish_domain_event(
        'order_guardian.escrow.release_requested',
        'protection_case',
        p_case_id,
        jsonb_build_object(
            'case_id', p_case_id,
            'order_reference', v_case.order_reference,
            'vendor_id', v_case.vendor_id,
            'customer_profile_id', v_case.customer_profile_id,
            'workspace_id', v_case.workspace_id
        ),
        v_case.workspace_id
    );

    RETURN jsonb_build_object('eligible', true, 'case_id', p_case_id, 'status', 'RELEASE_REQUESTED');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9.2 Expire Protection Windows Sweeper Procedure
CREATE OR REPLACE FUNCTION order_guardian.fn_expire_protection_windows()
RETURNS INTEGER AS $$
DECLARE
    v_rec RECORD;
    v_count INTEGER := 0;
BEGIN
    FOR v_rec IN 
        SELECT id FROM order_guardian.protection_cases 
        WHERE status IN ('ACTIVE', 'DELIVERY_VERIFIED') 
          AND protection_window_expires_at <= TIMEZONE('utc', NOW())
    LOOP
        PERFORM order_guardian.fn_evaluate_escrow_release(v_rec.id);
        v_count := v_count + 1;
    END LOOP;

    RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. ROW LEVEL SECURITY (RLS) POLICIES FOR ORDER GUARDIAN SCHEMA

ALTER TABLE order_guardian.protection_cases ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_guardian.delivery_verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_guardian.dispute_cases ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_guardian.evidence_files ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_guardian.trust_timelines ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_guardian.sla_trackers ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_guardian.risk_signals ENABLE ROW LEVEL SECURITY;

CREATE POLICY cases_own_read ON order_guardian.protection_cases FOR SELECT TO authenticated
    USING (
        customer_profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())
        OR vendor_id IN (SELECT id FROM public.vendors WHERE profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()))
        OR current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN', 'SUPPORT')
    );

CREATE POLICY dispute_cases_own_read ON order_guardian.dispute_cases FOR SELECT TO authenticated
    USING (
        raised_by_profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())
        OR current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN', 'SUPPORT')
    );

-- Winger Backend V2 - Sprint 3: Isolated Checkout System & Selcom Payment Gateway Integration
-- Migration: 20260806000003_sprint3_checkout_system.sql
-- Description: Creates checkout schema, enum_checkout_status, checkout.sessions, checkout.payment_logs, and fn_complete_checkout_session RPC.

-- 1. Create Isolated Checkout Schema
CREATE SCHEMA IF NOT EXISTS checkout;
GRANT USAGE ON SCHEMA checkout TO anon, authenticated, service_role;

-- 2. Checkout Status Enum
CREATE TYPE checkout.enum_checkout_status AS ENUM (
    'PENDING',
    'COMPLETED',
    'FAILED',
    'CANCELLED',
    'EXPIRED'
);

-- 3. Checkout Sessions Table (`checkout.sessions`)
CREATE TABLE checkout.sessions (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    cart_id UUID NULL REFERENCES public.carts(id) ON DELETE SET NULL,
    order_reference TEXT UNIQUE NOT NULL,
    amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
    currency public.enum_currency NOT NULL DEFAULT 'TZS',
    gateway TEXT NOT NULL DEFAULT 'SELCOM',
    gateway_session_id TEXT NULL,
    status checkout.enum_checkout_status NOT NULL DEFAULT 'PENDING',
    version INTEGER NOT NULL DEFAULT 1,
    expires_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW() + INTERVAL '30 minutes'),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_checkout_sessions_profile ON checkout.sessions(profile_id);
CREATE INDEX idx_checkout_sessions_reference ON checkout.sessions(order_reference);
CREATE INDEX idx_checkout_sessions_workspace ON checkout.sessions(workspace_id);

-- 4. Payment Callback Logs Table (`checkout.payment_logs`) - Idempotent Audit Store
CREATE TABLE checkout.payment_logs (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    session_id UUID NULL REFERENCES checkout.sessions(id) ON DELETE CASCADE,
    gateway_transaction_id TEXT UNIQUE NOT NULL,
    order_reference TEXT NOT NULL,
    raw_payload JSONB NOT NULL,
    signature_verified BOOLEAN NOT NULL DEFAULT FALSE,
    ip_address INET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_payment_logs_reference ON checkout.payment_logs(order_reference);
CREATE INDEX idx_payment_logs_tx_id ON checkout.payment_logs(gateway_transaction_id);

-- Trigger for updated_at
CREATE TRIGGER trg_checkout_sessions_updated_at 
    BEFORE UPDATE ON checkout.sessions 
    FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();

-- 5. Stored Procedure: Complete Checkout & Publish Event
CREATE OR REPLACE FUNCTION checkout.fn_complete_checkout_session(
    p_order_reference TEXT,
    p_gateway_tx_id TEXT,
    p_raw_payload JSONB,
    p_signature_verified BOOLEAN DEFAULT TRUE,
    p_client_ip INET DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_session RECORD;
    v_outbox_id UUID;
BEGIN
    -- Fetch active checkout session
    SELECT * INTO v_session
    FROM checkout.sessions
    WHERE order_reference = p_order_reference;

    IF v_session.id IS NULL THEN
        RAISE EXCEPTION 'Checkout session not found for reference %', p_order_reference USING ERRCODE = 'P0002';
    END IF;

    IF v_session.status = 'COMPLETED' THEN
        RETURN jsonb_build_object(
            'status', 'ALREADY_COMPLETED',
            'session_id', v_session.id,
            'message', 'Checkout session was previously completed'
        );
    END IF;

    -- Update session status to COMPLETED
    UPDATE checkout.sessions
    SET status = 'COMPLETED',
        updated_at = TIMEZONE('utc', NOW())
    WHERE id = v_session.id;

    -- Log payment callback event
    INSERT INTO checkout.payment_logs (
        session_id,
        gateway_transaction_id,
        order_reference,
        raw_payload,
        signature_verified,
        ip_address
    ) VALUES (
        v_session.id,
        p_gateway_tx_id,
        p_order_reference,
        p_raw_payload,
        p_signature_verified,
        p_client_ip
    );

    -- Publish transactional domain event to Outbox for Order Guardian processing
    v_outbox_id := public.fn_publish_domain_event(
        'checkout.payment.verified',
        'checkout_session',
        v_session.id,
        jsonb_build_object(
            'session_id', v_session.id,
            'order_reference', p_order_reference,
            'gateway_transaction_id', p_gateway_tx_id,
            'amount', v_session.amount,
            'currency', v_session.currency,
            'workspace_id', v_session.workspace_id,
            'profile_id', v_session.profile_id
        ),
        v_session.workspace_id
    );

    RETURN jsonb_build_object(
        'status', 'SUCCESS',
        'session_id', v_session.id,
        'outbox_id', v_outbox_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. ROW LEVEL SECURITY (RLS) POLICIES FOR CHECKOUT SCHEMA

ALTER TABLE checkout.sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE checkout.payment_logs ENABLE ROW LEVEL SECURITY;

-- Users can read their own checkout sessions
CREATE POLICY checkout_sessions_own_read
    ON checkout.sessions FOR SELECT
    TO authenticated
    USING (
        profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())
        OR current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN', 'FINANCE_MANAGER')
    );

-- Users can create checkout sessions for themselves
CREATE POLICY checkout_sessions_own_insert
    ON checkout.sessions FOR INSERT
    TO authenticated
    WITH CHECK (profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()));

-- Direct update/delete on checkout.sessions is blocked for client roles (handled via SECURITY DEFINER functions)
-- Payment logs read-only for Admins & Finance Managers
CREATE POLICY payment_logs_admin_read
    ON checkout.payment_logs FOR SELECT
    TO authenticated
    USING (current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN', 'FINANCE_MANAGER'));

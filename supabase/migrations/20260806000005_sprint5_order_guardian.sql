-- Winger Backend V2 - Sprint 5: Order Guardian Engine (Escrow Engine & State Machine)
-- Migration: 20260806000005_sprint5_order_guardian.sql
-- Description: Creates order_guardian.orders, order_items, escrows, disputes, state transition RPCs, and escrow release sweeper functions.

-- 1. Order Guardian Domain Enums
CREATE TYPE order_guardian.enum_order_status AS ENUM (
    'PENDING_PAYMENT',
    'PAID_ESCROW',
    'SHIPPED',
    'DELIVERED',
    'RELEASED',
    'DISPUTED',
    'REFUNDED',
    'CANCELLED'
);

CREATE TYPE order_guardian.enum_escrow_status AS ENUM (
    'LOCKED',
    'RELEASED',
    'DISPUTED',
    'REFUNDED'
);

CREATE TYPE order_guardian.enum_dispute_status AS ENUM (
    'OPEN',
    'UNDER_REVIEW',
    'RESOLVED_BUYER_REFUND',
    'RESOLVED_VENDOR_RELEASE',
    'DISMISSED'
);

-- 2. Master Orders Table (`order_guardian.orders`)
CREATE TABLE order_guardian.orders (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    buyer_profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    order_reference TEXT UNIQUE NOT NULL,
    total_amount NUMERIC(15, 2) NOT NULL CHECK (total_amount > 0),
    currency public.enum_currency NOT NULL DEFAULT 'TZS',
    status order_guardian.enum_order_status NOT NULL DEFAULT 'PENDING_PAYMENT',
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    deleted_at TIMESTAMPTZ NULL
);

CREATE INDEX idx_og_orders_workspace ON order_guardian.orders(workspace_id);
CREATE INDEX idx_og_orders_buyer ON order_guardian.orders(buyer_profile_id);
CREATE INDEX idx_og_orders_vendor ON order_guardian.orders(vendor_id);
CREATE INDEX idx_og_orders_status ON order_guardian.orders(status);

-- 3. Order Line Items Table (`order_guardian.order_items`)
CREATE TABLE order_guardian.order_items (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    order_id UUID NOT NULL REFERENCES order_guardian.orders(id) ON DELETE CASCADE,
    product_variant_id UUID NOT NULL REFERENCES public.product_variants(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(15, 2) NOT NULL CHECK (unit_price >= 0),
    subtotal NUMERIC(15, 2) NOT NULL CHECK (subtotal >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_og_order_items_order ON order_guardian.order_items(order_id);

-- 4. Escrows Table (`order_guardian.escrows`) - Financial Holding Store
CREATE TABLE order_guardian.escrows (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    order_id UUID UNIQUE NOT NULL REFERENCES order_guardian.orders(id) ON DELETE CASCADE,
    buyer_profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    vendor_profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    total_escrow_amount NUMERIC(15, 2) NOT NULL CHECK (total_escrow_amount >= 0),
    vendor_amount NUMERIC(15, 2) NOT NULL CHECK (vendor_amount >= 0),
    affiliate_amount NUMERIC(15, 2) NOT NULL DEFAULT 0 CHECK (affiliate_amount >= 0),
    platform_fee NUMERIC(15, 2) NOT NULL DEFAULT 0 CHECK (platform_fee >= 0),
    status order_guardian.enum_escrow_status NOT NULL DEFAULT 'LOCKED',
    auto_release_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW() + INTERVAL '7 days'),
    released_at TIMESTAMPTZ NULL,
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_og_escrows_order ON order_guardian.escrows(order_id);
CREATE INDEX idx_og_escrows_status_auto ON order_guardian.escrows(status, auto_release_at);

-- 5. Disputes Table (`order_guardian.disputes`) - Hold Resolution Store
CREATE TABLE order_guardian.disputes (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    order_id UUID NOT NULL REFERENCES order_guardian.orders(id) ON DELETE CASCADE,
    escrow_id UUID NOT NULL REFERENCES order_guardian.escrows(id) ON DELETE CASCADE,
    raised_by_profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    status order_guardian.enum_dispute_status NOT NULL DEFAULT 'OPEN',
    resolution_notes TEXT NULL,
    resolved_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_og_disputes_order ON order_guardian.disputes(order_id);
CREATE INDEX idx_og_disputes_status ON order_guardian.disputes(status);

-- Triggers for updated_at
CREATE TRIGGER trg_og_orders_updated_at BEFORE UPDATE ON order_guardian.orders FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();
CREATE TRIGGER trg_og_escrows_updated_at BEFORE UPDATE ON order_guardian.escrows FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();
CREATE TRIGGER trg_og_disputes_updated_at BEFORE UPDATE ON order_guardian.disputes FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();

-- 6. ORDER GUARDIAN STORED PROCEDURES & STATE MACHINE

-- 6.1 State Transition RPC
CREATE OR REPLACE FUNCTION order_guardian.fn_transition_order_status(
    p_order_id UUID,
    p_new_status order_guardian.enum_order_status,
    p_actor_profile_id UUID DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_order RECORD;
    v_valid_transition BOOLEAN := FALSE;
BEGIN
    SELECT * INTO v_order FROM order_guardian.orders WHERE id = p_order_id FOR UPDATE;

    IF v_order.id IS NULL THEN
        RAISE EXCEPTION 'Order % not found', p_order_id USING ERRCODE = 'P0002';
    END IF;

    -- State Machine Matrix Validation
    IF v_order.status = 'PENDING_PAYMENT' AND p_new_status IN ('PAID_ESCROW', 'CANCELLED') THEN
        v_valid_transition := TRUE;
    ELSIF v_order.status = 'PAID_ESCROW' AND p_new_status IN ('SHIPPED', 'DISPUTED', 'CANCELLED') THEN
        v_valid_transition := TRUE;
    ELSIF v_order.status = 'SHIPPED' AND p_new_status IN ('DELIVERED', 'DISPUTED') THEN
        v_valid_transition := TRUE;
    ELSIF v_order.status = 'DELIVERED' AND p_new_status IN ('RELEASED', 'DISPUTED') THEN
        v_valid_transition := TRUE;
    ELSIF v_order.status = 'DISPUTED' AND p_new_status IN ('RELEASED', 'REFUNDED') THEN
        v_valid_transition := TRUE;
    END IF;

    IF NOT v_valid_transition THEN
        RAISE EXCEPTION 'Illegal order state transition from % to %', v_order.status, p_new_status USING ERRCODE = '22000';
    END IF;

    -- Update order status
    UPDATE order_guardian.orders
    SET status = p_new_status,
        updated_at = TIMEZONE('utc', NOW())
    WHERE id = p_order_id;

    -- Publish state transition domain event
    PERFORM public.fn_publish_domain_event(
        'order_guardian.order.status_changed',
        'order',
        p_order_id,
        jsonb_build_object(
            'order_id', p_order_id,
            'old_status', v_order.status,
            'new_status', p_new_status,
            'actor_profile_id', p_actor_profile_id
        ),
        v_order.workspace_id
    );

    RETURN jsonb_build_object(
        'status', 'SUCCESS',
        'order_id', p_order_id,
        'old_status', v_order.status,
        'new_status', p_new_status
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6.2 Lock Escrow RPC (Triggered upon payment verification)
CREATE OR REPLACE FUNCTION order_guardian.fn_lock_order_escrow(
    p_workspace_id UUID,
    p_order_id UUID,
    p_buyer_profile_id UUID,
    p_vendor_profile_id UUID,
    p_total_amount NUMERIC,
    p_vendor_amount NUMERIC,
    p_affiliate_amount NUMERIC DEFAULT 0,
    p_platform_fee NUMERIC DEFAULT 0
)
RETURNS UUID AS $$
DECLARE
    v_escrow_id UUID;
BEGIN
    INSERT INTO order_guardian.escrows (
        workspace_id,
        order_id,
        buyer_profile_id,
        vendor_profile_id,
        total_escrow_amount,
        vendor_amount,
        affiliate_amount,
        platform_fee,
        status,
        auto_release_at
    ) VALUES (
        p_workspace_id,
        p_order_id,
        p_buyer_profile_id,
        p_vendor_profile_id,
        p_total_amount,
        p_vendor_amount,
        p_affiliate_amount,
        p_platform_fee,
        'LOCKED',
        TIMEZONE('utc', NOW() + INTERVAL '7 days')
    ) RETURNING id INTO v_escrow_id;

    -- Transition order to PAID_ESCROW
    PERFORM order_guardian.fn_transition_order_status(p_order_id, 'PAID_ESCROW');

    -- Publish Escrow Locked domain event
    PERFORM public.fn_publish_domain_event(
        'order_guardian.escrow.locked',
        'escrow',
        v_escrow_id,
        jsonb_build_object(
            'escrow_id', v_escrow_id,
            'order_id', p_order_id,
            'total_amount', p_total_amount
        ),
        p_workspace_id
    );

    RETURN v_escrow_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6.3 Release Escrow RPC
CREATE OR REPLACE FUNCTION order_guardian.fn_release_escrow(
    p_escrow_id UUID,
    p_actor_profile_id UUID DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_escrow RECORD;
BEGIN
    SELECT * INTO v_escrow FROM order_guardian.escrows WHERE id = p_escrow_id FOR UPDATE;

    IF v_escrow.id IS NULL THEN
        RAISE EXCEPTION 'Escrow % not found', p_escrow_id USING ERRCODE = 'P0002';
    END IF;

    IF v_escrow.status != 'LOCKED' THEN
        RAISE EXCEPTION 'Escrow % is not in LOCKED status (Current: %)', p_escrow_id, v_escrow.status USING ERRCODE = '22000';
    END IF;

    -- Update escrow status
    UPDATE order_guardian.escrows
    SET status = 'RELEASED',
        released_at = TIMEZONE('utc', NOW()),
        updated_at = TIMEZONE('utc', NOW())
    WHERE id = p_escrow_id;

    -- Update order status to RELEASED
    PERFORM order_guardian.fn_transition_order_status(v_escrow.order_id, 'RELEASED', p_actor_profile_id);

    -- Publish Escrow Released domain event for Wallet Ledger processing
    PERFORM public.fn_publish_domain_event(
        'order_guardian.escrow.released',
        'escrow',
        p_escrow_id,
        jsonb_build_object(
            'escrow_id', p_escrow_id,
            'order_id', v_escrow.order_id,
            'vendor_profile_id', v_escrow.vendor_profile_id,
            'vendor_amount', v_escrow.vendor_amount,
            'affiliate_amount', v_escrow.affiliate_amount,
            'platform_fee', v_escrow.platform_fee
        ),
        v_escrow.workspace_id
    );

    RETURN jsonb_build_object(
        'status', 'RELEASED',
        'escrow_id', p_escrow_id,
        'order_id', v_escrow.order_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6.4 Automated Release Sweeper RPC (Executed by pg_cron / Job Worker)
CREATE OR REPLACE FUNCTION order_guardian.fn_process_auto_release_sweeper()
RETURNS INTEGER AS $$
DECLARE
    v_rec RECORD;
    v_count INTEGER := 0;
BEGIN
    FOR v_rec IN 
        SELECT id FROM order_guardian.escrows 
        WHERE status = 'LOCKED' 
          AND auto_release_at <= TIMEZONE('utc', NOW())
          AND id NOT IN (SELECT escrow_id FROM order_guardian.disputes WHERE status IN ('OPEN', 'UNDER_REVIEW'))
    LOOP
        PERFORM order_guardian.fn_release_escrow(v_rec.id);
        v_count := v_count + 1;
    END LOOP;

    RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. ROW LEVEL SECURITY (RLS) POLICIES FOR ORDER GUARDIAN SCHEMA

ALTER TABLE order_guardian.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_guardian.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_guardian.escrows ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_guardian.disputes ENABLE ROW LEVEL SECURITY;

-- Orders RLS (Buyers & Vendors read own orders)
CREATE POLICY orders_own_read ON order_guardian.orders FOR SELECT TO authenticated
    USING (
        buyer_profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())
        OR vendor_id IN (SELECT id FROM public.vendors WHERE profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()))
        OR current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN', 'SUPPORT', 'FINANCE_MANAGER')
    );

-- Escrows RLS (Read-only for involved profiles & Admins)
CREATE POLICY escrows_own_read ON order_guardian.escrows FOR SELECT TO authenticated
    USING (
        buyer_profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())
        OR vendor_profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())
        OR current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN', 'FINANCE_MANAGER')
    );

-- Disputes RLS (Buyers & Vendors raise and view disputes)
CREATE POLICY disputes_own_read ON order_guardian.disputes FOR SELECT TO authenticated
    USING (
        raised_by_profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())
        OR current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN', 'SUPPORT')
    );

CREATE POLICY disputes_own_insert ON order_guardian.disputes FOR INSERT TO authenticated
    WITH CHECK (raised_by_profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()));

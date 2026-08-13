-- Winger Backend V2 - Sprint 7: Checkout System Architecture & Gateway Adapters
-- Migration: 20260806000010_sprint7_checkout_system.sql
-- Description: Extends checkout schema with checkout.sessions, session_items, pricing_snapshots, shipping_snapshots, inventory_reservations, payment_intents, payment_logs, timeline, state transition RPCs, and inventory sweeper procedures.

-- 1. Domain Enums
DO $$ BEGIN
    CREATE TYPE checkout.enum_checkout_state AS ENUM (
        'DRAFT',
        'VALIDATING',
        'READY_FOR_PAYMENT',
        'PAYMENT_PENDING',
        'PAYMENT_PROCESSING',
        'PAYMENT_SUCCESSFUL',
        'PAYMENT_FAILED',
        'CANCELLED',
        'EXPIRED',
        'COMPLETED'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE checkout.enum_payment_intent_status AS ENUM (
        'PENDING',
        'PROCESSING',
        'SUCCEEDED',
        'FAILED',
        'CANCELLED',
        'EXPIRED'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE checkout.enum_gateway_provider AS ENUM (
        'SELCOM',
        'MEETPAY',
        'STRIPE'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- 2. Checkout Sessions Root Aggregate (`checkout.sessions`)
DROP TABLE IF EXISTS checkout.timeline CASCADE;
DROP TABLE IF EXISTS checkout.payment_intents CASCADE;
DROP TABLE IF EXISTS checkout.inventory_reservations CASCADE;
DROP TABLE IF EXISTS checkout.shipping_snapshots CASCADE;
DROP TABLE IF EXISTS checkout.pricing_snapshots CASCADE;
DROP TABLE IF EXISTS checkout.session_items CASCADE;
DROP TABLE IF EXISTS checkout.sessions CASCADE;

CREATE TABLE checkout.sessions (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    customer_profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    order_reference TEXT UNIQUE NOT NULL,
    currency public.enum_currency NOT NULL DEFAULT 'TZS',
    subtotal NUMERIC(15, 2) NOT NULL CHECK (subtotal >= 0),
    shipping_cost NUMERIC(15, 2) NOT NULL DEFAULT 0 CHECK (shipping_cost >= 0),
    tax_amount NUMERIC(15, 2) NOT NULL DEFAULT 0 CHECK (tax_amount >= 0),
    discount_amount NUMERIC(15, 2) NOT NULL DEFAULT 0 CHECK (discount_amount >= 0),
    grand_total NUMERIC(15, 2) NOT NULL CHECK (grand_total >= 0),
    status checkout.enum_checkout_state NOT NULL DEFAULT 'DRAFT',
    expires_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW() + INTERVAL '30 minutes'),
    correlation_id TEXT NOT NULL,
    metadata JSONB NULL,
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    deleted_at TIMESTAMPTZ NULL
);

CREATE INDEX idx_checkout_sessions_workspace ON checkout.sessions(workspace_id);
CREATE INDEX idx_checkout_sessions_customer ON checkout.sessions(customer_profile_id);
CREATE INDEX idx_checkout_sessions_status ON checkout.sessions(status);

-- 3. Checkout Session Items Table (`checkout.session_items`)
CREATE TABLE checkout.session_items (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    session_id UUID NOT NULL REFERENCES checkout.sessions(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
    product_variant_id UUID NOT NULL REFERENCES public.product_variants(id) ON DELETE RESTRICT,
    product_name TEXT NOT NULL,
    variant_name TEXT NOT NULL,
    sku TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(15, 2) NOT NULL CHECK (unit_price >= 0),
    total_amount NUMERIC(15, 2) NOT NULL CHECK (total_amount >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_session_items_session ON checkout.session_items(session_id);

-- 4. Pricing Snapshots Table (`checkout.pricing_snapshots`)
CREATE TABLE checkout.pricing_snapshots (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    session_id UUID UNIQUE NOT NULL REFERENCES checkout.sessions(id) ON DELETE CASCADE,
    subtotal NUMERIC(15, 2) NOT NULL CHECK (subtotal >= 0),
    tax_amount NUMERIC(15, 2) NOT NULL DEFAULT 0,
    discount_amount NUMERIC(15, 2) NOT NULL DEFAULT 0,
    shipping_cost NUMERIC(15, 2) NOT NULL DEFAULT 0,
    grand_total NUMERIC(15, 2) NOT NULL CHECK (grand_total >= 0),
    currency public.enum_currency NOT NULL DEFAULT 'TZS',
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- 5. Shipping Snapshots Table (`checkout.shipping_snapshots`)
CREATE TABLE checkout.shipping_snapshots (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    session_id UUID UNIQUE NOT NULL REFERENCES checkout.sessions(id) ON DELETE CASCADE,
    recipient_name TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    address_line1 TEXT NOT NULL,
    city TEXT NOT NULL,
    region TEXT NOT NULL,
    country TEXT NOT NULL DEFAULT 'Tanzania',
    postal_code TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- 6. Inventory Reservations Table (`checkout.inventory_reservations`)
CREATE TABLE checkout.inventory_reservations (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    session_id UUID NOT NULL REFERENCES checkout.sessions(id) ON DELETE CASCADE,
    product_variant_id UUID NOT NULL REFERENCES public.product_variants(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    reserved_until TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW() + INTERVAL '15 minutes'),
    status TEXT NOT NULL DEFAULT 'RESERVED', -- 'RESERVED', 'RELEASED', 'COMMITTED'
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_reservations_variant ON checkout.inventory_reservations(product_variant_id);
CREATE INDEX idx_reservations_status_until ON checkout.inventory_reservations(status, reserved_until);

-- 7. Payment Intents Table (`checkout.payment_intents`)
CREATE TABLE checkout.payment_intents (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    session_id UUID NOT NULL REFERENCES checkout.sessions(id) ON DELETE CASCADE,
    gateway_provider checkout.enum_gateway_provider NOT NULL DEFAULT 'SELCOM',
    gateway_reference TEXT UNIQUE NOT NULL,
    payment_url TEXT NULL,
    amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
    currency public.enum_currency NOT NULL DEFAULT 'TZS',
    status checkout.enum_payment_intent_status NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_intents_session ON checkout.payment_intents(session_id);
CREATE INDEX idx_intents_gateway_ref ON checkout.payment_intents(gateway_reference);

-- 8. Checkout Timeline Table (`checkout.timeline`)
CREATE TABLE checkout.timeline (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    session_id UUID NOT NULL REFERENCES checkout.sessions(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT NULL,
    metadata JSONB NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_checkout_timeline_session ON checkout.timeline(session_id);

-- Triggers for updated_at
CREATE TRIGGER trg_checkout_sessions_updated_at BEFORE UPDATE ON checkout.sessions FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();
CREATE TRIGGER trg_inventory_res_updated_at BEFORE UPDATE ON checkout.inventory_reservations FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();
CREATE TRIGGER trg_payment_intents_updated_at BEFORE UPDATE ON checkout.payment_intents FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();

-- 9. STORED PROCEDURES & STATE MACHINE ENGINE

-- 9.1 State Machine Transition Procedure
CREATE OR REPLACE FUNCTION checkout.fn_transition_checkout_state(
    p_session_id UUID,
    p_target_state checkout.enum_checkout_state,
    p_reason TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_session RECORD;
    v_valid BOOLEAN := FALSE;
BEGIN
    SELECT * INTO v_session FROM checkout.sessions WHERE id = p_session_id FOR UPDATE;

    IF v_session.id IS NULL THEN
        RAISE EXCEPTION 'Checkout session % not found', p_session_id USING ERRCODE = 'P0002';
    END IF;

    -- Valid transition evaluation
    IF v_session.status = 'DRAFT' AND p_target_state IN ('VALIDATING', 'CANCELLED') THEN v_valid := TRUE;
    ELSIF v_session.status = 'VALIDATING' AND p_target_state IN ('READY_FOR_PAYMENT', 'PAYMENT_FAILED', 'CANCELLED') THEN v_valid := TRUE;
    ELSIF v_session.status = 'READY_FOR_PAYMENT' AND p_target_state IN ('PAYMENT_PENDING', 'CANCELLED', 'EXPIRED') THEN v_valid := TRUE;
    ELSIF v_session.status = 'PAYMENT_PENDING' AND p_target_state IN ('PAYMENT_PROCESSING', 'PAYMENT_FAILED', 'CANCELLED', 'EXPIRED') THEN v_valid := TRUE;
    ELSIF v_session.status = 'PAYMENT_PROCESSING' AND p_target_state IN ('PAYMENT_SUCCESSFUL', 'PAYMENT_FAILED') THEN v_valid := TRUE;
    ELSIF v_session.status = 'PAYMENT_SUCCESSFUL' AND p_target_state IN ('COMPLETED') THEN v_valid := TRUE;
    END IF;

    IF NOT v_valid THEN
        RAISE EXCEPTION 'Illegal checkout transition from % to %', v_session.status, p_target_state USING ERRCODE = '22000';
    END IF;

    -- Update session status
    UPDATE checkout.sessions
    SET status = p_target_state,
        updated_at = TIMEZONE('utc', NOW())
    WHERE id = p_session_id;

    -- Log timeline entry
    INSERT INTO checkout.timeline (session_id, event_type, title, description)
    VALUES (p_session_id, 'CHECKOUT_STATE_CHANGED', 'State updated to ' || p_target_state::text, p_reason);

    -- Publish platform outbox event
    PERFORM public.fn_publish_domain_event(
        'checkout.state.' || LOWER(p_target_state::text),
        'checkout_session',
        p_session_id,
        jsonb_build_object(
            'session_id', p_session_id,
            'order_reference', v_session.order_reference,
            'status', p_target_state,
            'grand_total', v_session.grand_total,
            'currency', v_session.currency
        ),
        v_session.workspace_id
    );

    RETURN jsonb_build_object(
        'status', 'SUCCESS',
        'session_id', p_session_id,
        'new_state', p_target_state
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9.2 Inventory Reservation Procedure
CREATE OR REPLACE FUNCTION checkout.fn_reserve_inventory(
    p_session_id UUID,
    p_ttl_minutes INTEGER DEFAULT 15
)
RETURNS INTEGER AS $$
DECLARE
    v_item RECORD;
    v_count INTEGER := 0;
BEGIN
    FOR v_item IN SELECT product_variant_id, quantity FROM checkout.session_items WHERE session_id = p_session_id
    LOOP
        INSERT INTO checkout.inventory_reservations (
            session_id, product_variant_id, quantity, reserved_until, status
        ) VALUES (
            p_session_id, v_item.product_variant_id, v_item.quantity, TIMEZONE('utc', NOW() + (p_ttl_minutes || ' minutes')::interval), 'RESERVED'
        );
        v_count := v_count + 1;
    END LOOP;

    RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9.3 Expired Inventory Reservation Release Sweeper Procedure
CREATE OR REPLACE FUNCTION checkout.fn_release_expired_reservations()
RETURNS INTEGER AS $$
DECLARE
    v_count INTEGER;
BEGIN
    WITH released AS (
        UPDATE checkout.inventory_reservations
        SET status = 'RELEASED',
            updated_at = TIMEZONE('utc', NOW())
        WHERE status = 'RESERVED'
          AND reserved_until <= TIMEZONE('utc', NOW())
        RETURNING id
    )
    SELECT COUNT(*) INTO v_count FROM released;

    RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. ROW LEVEL SECURITY (RLS) POLICIES FOR CHECKOUT SCHEMA

ALTER TABLE checkout.pricing_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE checkout.shipping_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE checkout.inventory_reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE checkout.payment_intents ENABLE ROW LEVEL SECURITY;
ALTER TABLE checkout.timeline ENABLE ROW LEVEL SECURITY;

CREATE POLICY pricing_own_read ON checkout.pricing_snapshots FOR SELECT TO authenticated
    USING (session_id IN (SELECT id FROM checkout.sessions WHERE customer_profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())));

CREATE POLICY shipping_own_read ON checkout.shipping_snapshots FOR SELECT TO authenticated
    USING (session_id IN (SELECT id FROM checkout.sessions WHERE customer_profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())));

CREATE POLICY intents_own_read ON checkout.payment_intents FOR SELECT TO authenticated
    USING (session_id IN (SELECT id FROM checkout.sessions WHERE customer_profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())));

-- Winger Backend V2 - Sprint 5: Orders Domain Implementation
-- Migration: 20260806000006_sprint5_orders_domain.sql
-- Description: Creates isolated orders schema, orders, order_items, shipping_details, fulfillments, deliveries, status_history, timeline, order number generator, and state machine RPCs.

-- 1. Create Isolated Orders Schema
CREATE SCHEMA IF NOT EXISTS orders;
GRANT USAGE ON SCHEMA orders TO anon, authenticated, service_role;

-- 2. Domain Enums
CREATE TYPE orders.enum_orders_status AS ENUM (
    'DRAFT',
    'PENDING_PAYMENT',
    'PAID',
    'CONFIRMED',
    'PREPARING',
    'READY_FOR_PICKUP',
    'IN_TRANSIT',
    'DELIVERED',
    'COMPLETED',
    'CANCELLED',
    'RETURNED',
    'REFUNDED',
    'DISPUTED'
);

CREATE TYPE orders.enum_fulfillment_status AS ENUM (
    'PENDING',
    'PREPARING',
    'PACKED',
    'READY',
    'COLLECTED',
    'FAILED'
);

CREATE TYPE orders.enum_delivery_status AS ENUM (
    'PENDING',
    'ASSIGNED',
    'PICKED_UP',
    'IN_TRANSIT',
    'DELIVERED',
    'FAILED',
    'RETURNED'
);

-- 3. Sequence for Human-Readable Order Numbers
CREATE SEQUENCE IF NOT EXISTS orders.order_number_seq START WITH 100001;

-- 4. Order Aggregate Root (`orders.orders`)
CREATE TABLE orders.orders (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    customer_profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    order_number TEXT UNIQUE NOT NULL,
    currency public.enum_currency NOT NULL DEFAULT 'TZS',
    subtotal NUMERIC(15, 2) NOT NULL CHECK (subtotal >= 0),
    shipping_cost NUMERIC(15, 2) NOT NULL DEFAULT 0 CHECK (shipping_cost >= 0),
    tax_amount NUMERIC(15, 2) NOT NULL DEFAULT 0 CHECK (tax_amount >= 0),
    discount_amount NUMERIC(15, 2) NOT NULL DEFAULT 0 CHECK (discount_amount >= 0),
    grand_total NUMERIC(15, 2) NOT NULL CHECK (grand_total >= 0),
    status orders.enum_orders_status NOT NULL DEFAULT 'DRAFT',
    fulfillment_status orders.enum_fulfillment_status NOT NULL DEFAULT 'PENDING',
    delivery_status orders.enum_delivery_status NOT NULL DEFAULT 'PENDING',
    customer_notes TEXT NULL,
    vendor_notes TEXT NULL,
    metadata JSONB NULL,
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    deleted_at TIMESTAMPTZ NULL
);

CREATE INDEX idx_orders_workspace ON orders.orders(workspace_id);
CREATE INDEX idx_orders_customer ON orders.orders(customer_profile_id);
CREATE INDEX idx_orders_vendor ON orders.orders(vendor_id);
CREATE INDEX idx_orders_number ON orders.orders(order_number);
CREATE INDEX idx_orders_status ON orders.orders(status);

-- 5. Order Items Table (`orders.order_items`) - Immutable Product & Price Snapshot
CREATE TABLE orders.order_items (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    order_id UUID NOT NULL REFERENCES orders.orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
    product_variant_id UUID NOT NULL REFERENCES public.product_variants(id) ON DELETE RESTRICT,
    product_name TEXT NOT NULL,
    variant_name TEXT NOT NULL,
    sku TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(15, 2) NOT NULL CHECK (unit_price >= 0),
    tax_amount NUMERIC(15, 2) NOT NULL DEFAULT 0 CHECK (tax_amount >= 0),
    discount_amount NUMERIC(15, 2) NOT NULL DEFAULT 0 CHECK (discount_amount >= 0),
    total_amount NUMERIC(15, 2) NOT NULL CHECK (total_amount >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_order_items_order ON orders.order_items(order_id);

-- 6. Shipping Details Table (`orders.shipping_details`)
CREATE TABLE orders.shipping_details (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    order_id UUID UNIQUE NOT NULL REFERENCES orders.orders(id) ON DELETE CASCADE,
    recipient_name TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    address_line1 TEXT NOT NULL,
    address_line2 TEXT NULL,
    city TEXT NOT NULL,
    region TEXT NOT NULL,
    country TEXT NOT NULL DEFAULT 'Tanzania',
    postal_code TEXT NULL,
    delivery_instructions TEXT NULL,
    shipping_method TEXT NOT NULL DEFAULT 'STANDARD',
    estimated_delivery_at TIMESTAMPTZ NULL,
    tracking_number TEXT NULL,
    courier_name TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_shipping_order ON orders.shipping_details(order_id);

-- 7. Fulfillments Table (`orders.fulfillments`)
CREATE TABLE orders.fulfillments (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    order_id UUID UNIQUE NOT NULL REFERENCES orders.orders(id) ON DELETE CASCADE,
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    status orders.enum_fulfillment_status NOT NULL DEFAULT 'PENDING',
    packed_at TIMESTAMPTZ NULL,
    ready_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_fulfillments_order ON orders.fulfillments(order_id);

-- 8. Deliveries Table (`orders.deliveries`)
CREATE TABLE orders.deliveries (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    order_id UUID UNIQUE NOT NULL REFERENCES orders.orders(id) ON DELETE CASCADE,
    shipping_id UUID NOT NULL REFERENCES orders.shipping_details(id) ON DELETE CASCADE,
    courier_id UUID NULL REFERENCES public.profiles(id) ON DELETE SET NULL,
    status orders.enum_delivery_status NOT NULL DEFAULT 'PENDING',
    picked_up_at TIMESTAMPTZ NULL,
    delivered_at TIMESTAMPTZ NULL,
    failed_reason TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_deliveries_order ON orders.deliveries(order_id);

-- 9. Status History Table (`orders.status_history`) - Immutable Log
CREATE TABLE orders.status_history (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    order_id UUID NOT NULL REFERENCES orders.orders(id) ON DELETE CASCADE,
    old_status orders.enum_orders_status NULL,
    new_status orders.enum_orders_status NOT NULL,
    actor_profile_id UUID NULL REFERENCES public.profiles(id) ON DELETE SET NULL,
    actor_role TEXT NULL,
    reason TEXT NULL,
    metadata JSONB NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_status_history_order ON orders.status_history(order_id);

-- 10. Timeline Table (`orders.timeline`) - Immutable Activity Log
CREATE TABLE orders.timeline (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    order_id UUID NOT NULL REFERENCES orders.orders(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT NULL,
    actor_profile_id UUID NULL REFERENCES public.profiles(id) ON DELETE SET NULL,
    metadata JSONB NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_timeline_order ON orders.timeline(order_id);

-- Triggers for updated_at
CREATE TRIGGER trg_orders_updated_at BEFORE UPDATE ON orders.orders FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();
CREATE TRIGGER trg_shipping_updated_at BEFORE UPDATE ON orders.shipping_details FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();
CREATE TRIGGER trg_fulfillments_updated_at BEFORE UPDATE ON orders.fulfillments FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();
CREATE TRIGGER trg_deliveries_updated_at BEFORE UPDATE ON orders.deliveries FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();

-- 11. STORED PROCEDURES & STATE MACHINE ENGINE

-- 11.1 Human-Readable Order Number Generator
CREATE OR REPLACE FUNCTION orders.fn_generate_order_number()
RETURNS TEXT AS $$
DECLARE
    v_date TEXT;
    v_seq BIGINT;
BEGIN
    v_date := TO_CHAR(TIMEZONE('utc', NOW()), 'YYYYMMDD');
    v_seq := nextval('orders.order_number_seq');
    RETURN 'WNG-' || v_date || '-' || LPAD(v_seq::text, 6, '0');
END;
$$ LANGUAGE plpgsql;

-- 11.2 State Transition Procedure
CREATE OR REPLACE FUNCTION orders.fn_transition_order_status(
    p_order_id UUID,
    p_new_status orders.enum_orders_status,
    p_actor_profile_id UUID DEFAULT NULL,
    p_reason TEXT DEFAULT NULL,
    p_metadata JSONB DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_order RECORD;
    v_valid BOOLEAN := FALSE;
    v_event_type TEXT;
BEGIN
    SELECT * INTO v_order FROM orders.orders WHERE id = p_order_id FOR UPDATE;

    IF v_order.id IS NULL THEN
        RAISE EXCEPTION 'Order % not found', p_order_id USING ERRCODE = 'P0002';
    END IF;

    -- Valid Transition Evaluation Matrix
    IF v_order.status = 'DRAFT' AND p_new_status IN ('PENDING_PAYMENT', 'CANCELLED') THEN v_valid := TRUE;
    ELSIF v_order.status = 'PENDING_PAYMENT' AND p_new_status IN ('PAID', 'CANCELLED') THEN v_valid := TRUE;
    ELSIF v_order.status = 'PAID' AND p_new_status IN ('CONFIRMED', 'CANCELLED') THEN v_valid := TRUE;
    ELSIF v_order.status = 'CONFIRMED' AND p_new_status IN ('PREPARING', 'CANCELLED') THEN v_valid := TRUE;
    ELSIF v_order.status = 'PREPARING' AND p_new_status IN ('READY_FOR_PICKUP', 'CANCELLED') THEN v_valid := TRUE;
    ELSIF v_order.status = 'READY_FOR_PICKUP' AND p_new_status IN ('IN_TRANSIT', 'CANCELLED') THEN v_valid := TRUE;
    ELSIF v_order.status = 'IN_TRANSIT' AND p_new_status IN ('DELIVERED', 'DISPUTED') THEN v_valid := TRUE;
    ELSIF v_order.status = 'DELIVERED' AND p_new_status IN ('COMPLETED', 'RETURNED', 'DISPUTED') THEN v_valid := TRUE;
    ELSIF v_order.status = 'DISPUTED' AND p_new_status IN ('COMPLETED', 'REFUNDED') THEN v_valid := TRUE;
    END IF;

    IF NOT v_valid THEN
        RAISE EXCEPTION 'Illegal order transition from % to %', v_order.status, p_new_status USING ERRCODE = '22000';
    END IF;

    -- Update order record
    UPDATE orders.orders
    SET status = p_new_status,
        updated_at = TIMEZONE('utc', NOW())
    WHERE id = p_order_id;

    -- Record immutable status history
    INSERT INTO orders.status_history (
        order_id, old_status, new_status, actor_profile_id, reason, metadata
    ) VALUES (
        p_order_id, v_order.status, p_new_status, p_actor_profile_id, p_reason, p_metadata
    );

    -- Add timeline entry
    INSERT INTO orders.timeline (
        order_id, event_type, title, description, actor_profile_id, metadata
    ) VALUES (
        p_order_id,
        'ORDER_STATUS_CHANGED',
        'Order status updated to ' || p_new_status::text,
        COALESCE(p_reason, 'Status updated via state machine'),
        p_actor_profile_id,
        p_metadata
    );

    -- Publish Platform Domain Event to Outbox
    v_event_type := 'orders.order.' || LOWER(p_new_status::text);
    PERFORM public.fn_publish_domain_event(
        v_event_type,
        'order',
        p_order_id,
        jsonb_build_object(
            'order_id', p_order_id,
            'order_number', v_order.order_number,
            'old_status', v_order.status,
            'new_status', p_new_status,
            'grand_total', v_order.grand_total,
            'currency', v_order.currency,
            'workspace_id', v_order.workspace_id,
            'customer_profile_id', v_order.customer_profile_id,
            'vendor_id', v_order.vendor_id
        ),
        v_order.workspace_id
    );

    RETURN jsonb_build_object(
        'status', 'SUCCESS',
        'order_id', p_order_id,
        'order_number', v_order.order_number,
        'new_status', p_new_status
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 12. ROW LEVEL SECURITY (RLS) POLICIES FOR ORDERS SCHEMA

ALTER TABLE orders.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders.shipping_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders.fulfillments ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders.deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders.status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders.timeline ENABLE ROW LEVEL SECURITY;

-- Customer can read own orders
CREATE POLICY orders_customer_read ON orders.orders FOR SELECT TO authenticated
    USING (customer_profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()));

-- Vendor can read & manage orders belonging to their organization
CREATE POLICY orders_vendor_read ON orders.orders FOR SELECT TO authenticated
    USING (vendor_id IN (SELECT id FROM public.vendors WHERE profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())));

-- Items read policies
CREATE POLICY order_items_read ON orders.order_items FOR SELECT TO authenticated
    USING (order_id IN (SELECT id FROM orders.orders WHERE customer_profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()) OR vendor_id IN (SELECT id FROM public.vendors WHERE profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()))));

-- Shipping, Fulfillments, Timeline read policies
CREATE POLICY shipping_read ON orders.shipping_details FOR SELECT TO authenticated
    USING (order_id IN (SELECT id FROM orders.orders));

CREATE POLICY timeline_read ON orders.timeline FOR SELECT TO authenticated
    USING (order_id IN (SELECT id FROM orders.orders));

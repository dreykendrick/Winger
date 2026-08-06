-- Winger Backend V2 - Sprint 7: Notification Engine & Realtime Event Dispatcher
-- Migration: 20260806000008_sprint7_notification_engine.sql
-- Description: Creates isolated notifications schema, templates, user_preferences, notifications log, and dispatch RPC.

-- 1. Create Isolated Notifications Schema
CREATE SCHEMA IF NOT EXISTS notifications;
GRANT USAGE ON SCHEMA notifications TO anon, authenticated, service_role;

-- 2. Domain Enums
CREATE TYPE notifications.enum_notification_channel AS ENUM (
    'IN_APP',
    'PUSH',
    'EMAIL',
    'SMS'
);

CREATE TYPE notifications.enum_notification_status AS ENUM (
    'UNREAD',
    'READ',
    'DISMISSED'
);

-- 3. Notification Templates Table (`notifications.templates`)
CREATE TABLE notifications.templates (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    event_type TEXT NOT NULL,
    channel notifications.enum_notification_channel NOT NULL DEFAULT 'IN_APP',
    subject_template TEXT NOT NULL,
    body_template TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    CONSTRAINT uq_template_event_channel UNIQUE (event_type, channel)
);

CREATE INDEX idx_templates_event ON notifications.templates(event_type);

-- 4. User Notification Preferences Table (`notifications.user_preferences`)
CREATE TABLE notifications.user_preferences (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    profile_id UUID UNIQUE NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    in_app_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    push_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    email_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    sms_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_notif_prefs_profile ON notifications.user_preferences(profile_id);

-- 5. User Notifications Log Table (`notifications.notifications`)
CREATE TABLE notifications.notifications (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,
    channel notifications.enum_notification_channel NOT NULL DEFAULT 'IN_APP',
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    status notifications.enum_notification_status NOT NULL DEFAULT 'UNREAD',
    read_at TIMESTAMPTZ NULL,
    metadata JSONB NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_notifications_profile ON notifications.notifications(profile_id);
CREATE INDEX idx_notifications_status ON notifications.notifications(status);

-- Triggers for updated_at
CREATE TRIGGER trg_templates_updated_at BEFORE UPDATE ON notifications.templates FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();
CREATE TRIGGER trg_notif_prefs_updated_at BEFORE UPDATE ON notifications.user_preferences FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();

-- Enable Supabase Realtime for Notifications Table
ALTER PUBLICATION supabase_realtime ADD TABLE notifications.notifications;

-- Seed Default Notification Templates
INSERT INTO notifications.templates (event_type, channel, subject_template, body_template) VALUES
    ('orders.order.created', 'IN_APP', 'Order Placed', 'Your order {{order_number}} for {{grand_total}} TZS has been placed successfully.'),
    ('orders.order.paid', 'IN_APP', 'Payment Confirmed', 'Payment confirmed for order {{order_number}}. Merchant is preparing your shipment.'),
    ('orders.order.shipped', 'IN_APP', 'Order Shipped', 'Your order {{order_number}} is on the way! Tracking: {{tracking_number}}.'),
    ('orders.order.delivered', 'IN_APP', 'Order Delivered', 'Your order {{order_number}} has been delivered. Please confirm receipt.'),
    ('growth.commission.calculated', 'IN_APP', 'Commission Earned!', 'You earned {{commission_amount}} TZS commission from referral order.'),
    ('order_guardian.escrow.released', 'IN_APP', 'Funds Released', 'Escrow funds of {{vendor_amount}} TZS have been released to your vendor balance.')
ON CONFLICT (event_type, channel) DO NOTHING;

-- 6. STORED PROCEDURE FOR NOTIFICATION DISPATCH
CREATE OR REPLACE FUNCTION notifications.fn_dispatch_notification(
    p_profile_id UUID,
    p_event_type TEXT,
    p_title TEXT,
    p_content TEXT,
    p_metadata JSONB DEFAULT NULL,
    p_channel notifications.enum_notification_channel DEFAULT 'IN_APP'
)
RETURNS UUID AS $$
DECLARE
    v_pref RECORD;
    v_notif_id UUID;
BEGIN
    -- Check user preferences
    SELECT * INTO v_pref FROM notifications.user_preferences WHERE profile_id = p_profile_id;

    IF v_pref.id IS NOT NULL THEN
        IF p_channel = 'IN_APP' AND NOT v_pref.in_app_enabled THEN RETURN NULL; END IF;
        IF p_channel = 'PUSH' AND NOT v_pref.push_enabled THEN RETURN NULL; END IF;
        IF p_channel = 'EMAIL' AND NOT v_pref.email_enabled THEN RETURN NULL; END IF;
        IF p_channel = 'SMS' AND NOT v_pref.sms_enabled THEN RETURN NULL; END IF;
    END IF;

    -- Insert notification record
    INSERT INTO notifications.notifications (
        profile_id, event_type, channel, title, content, status, metadata
    ) VALUES (
        p_profile_id, p_event_type, p_channel, p_title, p_content, 'UNREAD', p_metadata
    ) RETURNING id INTO v_notif_id;

    RETURN v_notif_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. ROW LEVEL SECURITY (RLS) POLICIES FOR NOTIFICATIONS SCHEMA

ALTER TABLE notifications.templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications.notifications ENABLE ROW LEVEL SECURITY;

-- Templates RLS (Read-only for authenticated users)
CREATE POLICY templates_read ON notifications.templates FOR SELECT TO authenticated USING (is_active = TRUE);

-- Preferences RLS (Users manage their own preferences)
CREATE POLICY prefs_own_read ON notifications.user_preferences FOR SELECT TO authenticated
    USING (profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()));

CREATE POLICY prefs_own_update ON notifications.user_preferences FOR UPDATE TO authenticated
    USING (profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()));

-- Notifications RLS (Users read and manage their own notifications)
CREATE POLICY notifications_own_read ON notifications.notifications FOR SELECT TO authenticated
    USING (profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()));

CREATE POLICY notifications_own_update ON notifications.notifications FOR UPDATE TO authenticated
    USING (profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()));

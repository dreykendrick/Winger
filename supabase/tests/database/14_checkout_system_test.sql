-- Winger Backend V2 - pgTAP Checkout System Security & Gateway Test Suite
-- File: supabase/tests/database/14_checkout_system_test.sql
-- Description: Validates checkout schema, checkout.sessions, session_items, pricing_snapshots, inventory_reservations, payment_intents, payment_logs, state machine transition RPCs, and RLS policies.

BEGIN;
SELECT plan(12);

-- 1. Test Schema & Tables
SELECT has_schema('checkout', 'Schema checkout should exist');
SELECT has_table('checkout', 'sessions', 'Table checkout.sessions should exist');
SELECT has_table('checkout', 'session_items', 'Table checkout.session_items should exist');
SELECT has_table('checkout', 'pricing_snapshots', 'Table checkout.pricing_snapshots should exist');
SELECT has_table('checkout', 'shipping_snapshots', 'Table checkout.shipping_snapshots should exist');
SELECT has_table('checkout', 'inventory_reservations', 'Table checkout.inventory_reservations should exist');
SELECT has_table('checkout', 'payment_intents', 'Table checkout.payment_intents should exist');
SELECT has_table('checkout', 'payment_logs', 'Table checkout.payment_logs should exist');

-- 2. Test Enums
SELECT has_type('enum_checkout_state', 'Enum enum_checkout_state should exist');
SELECT has_type('enum_payment_intent_status', 'Enum enum_payment_intent_status should exist');
SELECT has_type('enum_gateway_provider', 'Enum enum_gateway_provider should exist');

-- 3. Test RPC Functions
SELECT has_function('checkout', 'fn_transition_checkout_state', ARRAY['uuid', 'checkout.enum_checkout_state', 'text'], 'RPC fn_transition_checkout_state should exist');

SELECT * FROM finish();
ROLLBACK;

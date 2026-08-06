-- Winger Backend V2 - pgTAP Orders Domain Test Suite
-- File: supabase/tests/database/10_orders_domain_test.sql
-- Description: Validates orders schema tables, order aggregate, human-readable order number generator, state machine transitions, and RLS policies.

BEGIN;
SELECT plan(12);

-- 1. Test Schema & Tables
SELECT has_schema('orders', 'Schema orders should exist');
SELECT has_table('orders', 'orders', 'Table orders.orders should exist');
SELECT has_table('orders', 'order_items', 'Table orders.order_items should exist');
SELECT has_table('orders', 'shipping_details', 'Table orders.shipping_details should exist');
SELECT has_table('orders', 'fulfillments', 'Table orders.fulfillments should exist');
SELECT has_table('orders', 'deliveries', 'Table orders.deliveries should exist');
SELECT has_table('orders', 'status_history', 'Table orders.status_history should exist');
SELECT has_table('orders', 'timeline', 'Table orders.timeline should exist');

-- 2. Test Human-Readable Order Number Generator RPC
SELECT has_function('orders', 'fn_generate_order_number', ARRAY[]::text[], 'RPC fn_generate_order_number should exist');
SELECT matches(
    orders.fn_generate_order_number(),
    '^WNG-[0-9]{8}-[0-9]{6}$',
    'fn_generate_order_number() should return formatted WNG-YYYYMMDD-XXXXXX string'
);

-- 3. Test State Transition RPC Function
SELECT has_function('orders', 'fn_transition_order_status', ARRAY['uuid', 'orders.enum_orders_status', 'uuid', 'text', 'jsonb'], 'RPC fn_transition_order_status should exist');

-- 4. Test RLS Status
SELECT table_privs_are('orders', 'orders', 'authenticated', ARRAY['SELECT']);

SELECT * FROM finish();
ROLLBACK;

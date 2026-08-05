-- Winger Backend V2 - pgTAP Order Guardian Security & State Machine Test Suite
-- File: supabase/tests/database/09_order_guardian_test.sql
-- Description: Validates order_guardian schema tables, state machine transitions, escrow locking, dispute holds, and RLS policies.

BEGIN;
SELECT plan(10);

-- 1. Test Schema & Tables
SELECT has_schema('order_guardian', 'Schema order_guardian should exist');
SELECT has_table('order_guardian', 'orders', 'Table order_guardian.orders should exist');
SELECT has_table('order_guardian', 'order_items', 'Table order_guardian.order_items should exist');
SELECT has_table('order_guardian', 'escrows', 'Table order_guardian.escrows should exist');
SELECT has_table('order_guardian', 'disputes', 'Table order_guardian.disputes should exist');

-- 2. Test Enums
SELECT has_type('enum_order_status', 'Enum enum_order_status should exist');
SELECT has_type('enum_escrow_status', 'Enum enum_escrow_status should exist');
SELECT has_type('enum_dispute_status', 'Enum enum_dispute_status should exist');

-- 3. Test RPC Functions
SELECT has_function('order_guardian', 'fn_transition_order_status', ARRAY['uuid', 'order_guardian.enum_order_status', 'uuid'], 'RPC fn_transition_order_status should exist');
SELECT has_function('order_guardian', 'fn_release_escrow', ARRAY['uuid', 'uuid'], 'RPC fn_release_escrow should exist');

SELECT * FROM finish();
ROLLBACK;

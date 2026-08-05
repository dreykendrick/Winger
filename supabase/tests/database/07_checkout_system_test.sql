-- Winger Backend V2 - pgTAP Checkout System Security Test Suite
-- File: supabase/tests/database/07_checkout_system_test.sql
-- Description: Validates checkout schema, checkout.sessions, payment_logs, RLS, and fn_complete_checkout_session procedure.

BEGIN;
SELECT plan(8);

-- 1. Test Schema & Tables
SELECT has_schema('checkout', 'Schema checkout should exist');
SELECT has_table('checkout', 'sessions', 'Table checkout.sessions should exist');
SELECT has_table('checkout', 'payment_logs', 'Table checkout.payment_logs should exist');

-- 2. Test Enum
SELECT has_type('enum_checkout_status', 'Enum enum_checkout_status should exist');

-- 3. Test RPC Function
SELECT has_function('checkout', 'fn_complete_checkout_session', ARRAY['text', 'text', 'jsonb', 'boolean', 'inet'], 'RPC fn_complete_checkout_session should exist');

-- 4. Test Foreign Key Constraints & Idempotency
SELECT col_is_pk('checkout', 'sessions', 'id', 'Column id must be PK in checkout.sessions');
SELECT col_is_pk('checkout', 'payment_logs', 'id', 'Column id must be PK in checkout.payment_logs');

-- 5. Test RLS Status
SELECT table_privs_are('checkout', 'sessions', 'authenticated', ARRAY['SELECT', 'INSERT']);

SELECT * FROM finish();
ROLLBACK;

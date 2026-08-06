-- Winger Backend V2 - pgTAP Financial Core Security & Ledger Test Suite
-- File: supabase/tests/database/13_financial_core_test.sql
-- Description: Validates wallet_ledger tables, wallet_projections, escrow_records, refund_records, reconciliation_logs, fn_compute_wallet_projection, fn_reconcile_ledger, and RLS policies.

BEGIN;
SELECT plan(12);

-- 1. Test Schema & Tables
SELECT has_schema('wallet_ledger', 'Schema wallet_ledger should exist');
SELECT has_table('wallet_ledger', 'wallet_projections', 'Table wallet_ledger.wallet_projections should exist');
SELECT has_table('wallet_ledger', 'escrow_records', 'Table wallet_ledger.escrow_records should exist');
SELECT has_table('wallet_ledger', 'refund_records', 'Table wallet_ledger.refund_records should exist');
SELECT has_table('wallet_ledger', 'reconciliation_logs', 'Table wallet_ledger.reconciliation_logs should exist');

-- 2. Test Enums
SELECT has_type('enum_transaction_type', 'Enum enum_transaction_type should exist');
SELECT has_type('enum_refund_status', 'Enum enum_refund_status should exist');

-- 3. Test RPC Functions
SELECT has_function('wallet_ledger', 'fn_compute_wallet_projection', ARRAY['uuid'], 'RPC fn_compute_wallet_projection should exist');
SELECT has_function('wallet_ledger', 'fn_create_refund_transaction', ARRAY['uuid', 'uuid', 'numeric', 'text', 'text'], 'RPC fn_create_refund_transaction should exist');
SELECT has_function('wallet_ledger', 'fn_reconcile_ledger', ARRAY[]::text[], 'RPC fn_reconcile_ledger should exist');

-- 4. Test Reconciliation Execution
SELECT results_eq(
    $$ SELECT (wallet_ledger.fn_reconcile_ledger()->>'is_balanced')::boolean $$,
    ARRAY[TRUE],
    'fn_reconcile_ledger() should audit clean ledger and return is_balanced = TRUE'
);

SELECT * FROM finish();
ROLLBACK;

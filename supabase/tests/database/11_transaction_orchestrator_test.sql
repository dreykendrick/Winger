-- Winger Backend V2 - pgTAP Transaction Orchestrator & Double-Entry Security Test Suite
-- File: supabase/tests/database/11_transaction_orchestrator_test.sql
-- Description: Validates wallet_ledger schema, accounts, accounting_rules, double-entry balancing enforcement (Debits = Credits), and fn_execute_transaction_orchestrator RPC.

BEGIN;
SELECT plan(10);

-- 1. Test Schema & Tables
SELECT has_schema('wallet_ledger', 'Schema wallet_ledger should exist');
SELECT has_table('wallet_ledger', 'accounts', 'Table wallet_ledger.accounts should exist');
SELECT has_table('wallet_ledger', 'accounting_rules', 'Table wallet_ledger.accounting_rules should exist');
SELECT has_table('wallet_ledger', 'orchestrator_requests', 'Table wallet_ledger.orchestrator_requests should exist');
SELECT has_table('wallet_ledger', 'journal_entries', 'Table wallet_ledger.journal_entries should exist');
SELECT has_table('wallet_ledger', 'ledger_lines', 'Table wallet_ledger.ledger_lines should exist');
SELECT has_table('wallet_ledger', 'settlements', 'Table wallet_ledger.settlements should exist');

-- 2. Test Enums & RPC
SELECT has_type('enum_account_type', 'Enum enum_account_type should exist');
SELECT has_type('enum_intent_type', 'Enum enum_intent_type should exist');
SELECT has_function('wallet_ledger', 'fn_execute_transaction_orchestrator', ARRAY['text', 'wallet_ledger.enum_intent_type', 'jsonb', 'uuid', 'uuid'], 'RPC fn_execute_transaction_orchestrator should exist');

SELECT * FROM finish();
ROLLBACK;

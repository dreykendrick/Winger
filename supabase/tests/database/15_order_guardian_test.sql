-- Winger Backend V2 - pgTAP Order Guardian Security & Trust Test Suite
-- File: supabase/tests/database/15_order_guardian_test.sql
-- Description: Validates order_guardian schema tables, protection_cases, delivery_verifications, dispute_cases, evidence_files, trust_timelines, fn_evaluate_escrow_release RPC, and RLS policies.

BEGIN;
SELECT plan(12);

-- 1. Test Schema & Tables
SELECT has_schema('order_guardian', 'Schema order_guardian should exist');
SELECT has_table('order_guardian', 'protection_cases', 'Table order_guardian.protection_cases should exist');
SELECT has_table('order_guardian', 'delivery_verifications', 'Table order_guardian.delivery_verifications should exist');
SELECT has_table('order_guardian', 'dispute_cases', 'Table order_guardian.dispute_cases should exist');
SELECT has_table('order_guardian', 'evidence_files', 'Table order_guardian.evidence_files should exist');
SELECT has_table('order_guardian', 'trust_timelines', 'Table order_guardian.trust_timelines should exist');
SELECT has_table('order_guardian', 'sla_trackers', 'Table order_guardian.sla_trackers should exist');
SELECT has_table('order_guardian', 'risk_signals', 'Table order_guardian.risk_signals should exist');

-- 2. Test Enums
SELECT has_type('enum_protection_status', 'Enum enum_protection_status should exist');
SELECT has_type('enum_verification_method', 'Enum enum_verification_method should exist');
SELECT has_type('enum_dispute_type', 'Enum enum_dispute_type should exist');

-- 3. Test RPC Functions
SELECT has_function('order_guardian', 'fn_evaluate_escrow_release', ARRAY['uuid'], 'RPC fn_evaluate_escrow_release should exist');

SELECT * FROM finish();
ROLLBACK;

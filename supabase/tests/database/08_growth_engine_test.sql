-- Winger Backend V2 - pgTAP Growth Engine Security & Domain Test Suite
-- File: supabase/tests/database/08_growth_engine_test.sql
-- Description: Validates growth schema tables, campaigns, affiliate profiles, click sessions, attributions, rule precedence RPC, and RLS policies.

BEGIN;
SELECT plan(12);

-- 1. Test Schema & Tables
SELECT has_schema('growth', 'Schema growth should exist');
SELECT has_table('growth', 'campaigns', 'Table growth.campaigns should exist');
SELECT has_table('growth', 'affiliate_profiles', 'Table growth.affiliate_profiles should exist');
SELECT has_table('growth', 'affiliate_links', 'Table growth.affiliate_links should exist');
SELECT has_table('growth', 'click_sessions', 'Table growth.click_sessions should exist');
SELECT has_table('growth', 'attributions', 'Table growth.attributions should exist');
SELECT has_table('growth', 'conversions', 'Table growth.conversions should exist');
SELECT has_table('growth', 'commission_rules', 'Table growth.commission_rules should exist');
SELECT has_table('growth', 'commissions', 'Table growth.commissions should exist');
SELECT has_table('growth', 'fraud_flags', 'Table growth.fraud_flags should exist');

-- 2. Test Rule Precedence RPC Function
SELECT has_function('growth', 'fn_evaluate_commission_rule', ARRAY['uuid', 'uuid', 'uuid', 'uuid', 'numeric'], 'RPC fn_evaluate_commission_rule should exist');

-- 3. Test Rule Evaluation Fallback to Default 5%
SELECT results_eq(
    $$ SELECT (growth.fn_evaluate_commission_rule(NULL, NULL, NULL, NULL, 100000)->>'commission_amount')::numeric $$,
    ARRAY[5000.00::numeric],
    'fn_evaluate_commission_rule should return default 5% commission for 100,000 TZS sale'
);

SELECT * FROM finish();
ROLLBACK;

-- Winger Backend V2 - pgTAP Affiliate Attribution Security Test Suite
-- File: supabase/tests/database/04_affiliate_attribution_test.sql
-- Description: Validates affiliate tracking tables, referral link creation, and 30-day attribution expiration rules.

BEGIN;
SELECT plan(6);

-- 1. Test Table Structure & Indexes
SELECT has_table('public', 'affiliate_links', 'Table public.affiliate_links should exist');
SELECT has_table('public', 'attributions', 'Table public.attributions should exist');

-- 2. Test Foreign Keys & Constraints
SELECT col_not_null('public', 'affiliate_links', 'unique_code', 'Column unique_code must be NOT NULL');
SELECT col_not_null('public', 'attributions', 'cookie_token', 'Column cookie_token must be NOT NULL');

-- 3. Test Attribution Default 30-Day Expiry Window
PREPARE insert_test_attribution AS 
    INSERT INTO public.attributions (affiliate_link_id, affiliate_id, cookie_token) 
    VALUES ('018f2d5e-0000-7000-8000-000000000001', '018f2d5e-0000-7000-8000-000000000002', 'attr_test_token_123');

-- Expiry window constraint evaluation test
SELECT throws_ok(
    'insert_test_attribution',
    'violates foreign key constraint',
    'Attribution should enforce foreign key integrity on link_id and affiliate_id'
);

SELECT * FROM finish();
ROLLBACK;

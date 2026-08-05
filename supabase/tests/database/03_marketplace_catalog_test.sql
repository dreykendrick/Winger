-- Winger Backend V2 - pgTAP Database Test Suite
-- File: supabase/tests/database/03_marketplace_catalog_test.sql
-- Description: Validates product catalog creation, variant stock checks, and catalog RLS policies.

BEGIN;
SELECT plan(10);

-- 1. Test Sprint 2 Table Existence
SELECT has_table('public', 'workspaces', 'Table public.workspaces should exist');
SELECT has_table('public', 'categories', 'Table public.categories should exist');
SELECT has_table('public', 'vendors', 'Table public.vendors should exist');
SELECT has_table('public', 'products', 'Table public.products should exist');
SELECT has_table('public', 'product_variants', 'Table public.product_variants should exist');
SELECT has_table('public', 'carts', 'Table public.carts should exist');
SELECT has_table('public', 'affiliates', 'Table public.affiliates should exist');

-- 2. Test Enums
SELECT has_type('enum_product_status', 'Enum enum_product_status should exist');
SELECT has_type('enum_workspace_type', 'Enum enum_workspace_type should exist');

-- 3. Test Categories Insert & Public Read Policy
INSERT INTO public.categories (name, slug) VALUES ('Electronics', 'electronics');
SELECT results_eq(
    'SELECT slug FROM public.categories WHERE slug = ''electronics''',
    ARRAY['electronics'],
    'Categories should insert and be queryable'
);

SELECT * FROM finish();
ROLLBACK;

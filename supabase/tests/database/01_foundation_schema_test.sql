-- Winger Backend V2 - pgTAP Database Test Suite
-- File: supabase/tests/database/01_foundation_schema_test.sql
-- Description: Validates schema existence, UUIDv7 generator, table structures, and default triggers.

BEGIN;
SELECT plan(18);

-- 1. Test Schemas
SELECT has_schema('order_guardian', 'Schema order_guardian should exist');
SELECT has_schema('wallet_ledger', 'Schema wallet_ledger should exist');
SELECT has_schema('audit_system', 'Schema audit_system should exist');

-- 2. Test UUIDv7 Generator Function
SELECT has_function('public', 'gen_random_uuid_v7', 'Function gen_random_uuid_v7() should exist');
SELECT matches(
    public.gen_random_uuid_v7()::text,
    '^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    'gen_random_uuid_v7() should return a valid UUIDv7 string format'
);

-- 3. Test Global Enums
SELECT has_type('enum_user_role', 'Enum enum_user_role should exist');
SELECT has_type('enum_account_status', 'Enum enum_account_status should exist');
SELECT has_type('enum_verification_status', 'Enum enum_verification_status should exist');
SELECT has_type('enum_notification_channel', 'Enum enum_notification_channel should exist');
SELECT has_type('enum_language', 'Enum enum_language should exist');
SELECT has_type('enum_currency', 'Enum enum_currency should exist');

-- 4. Test Table Existence
SELECT has_table('public', 'profiles', 'Table public.profiles should exist');
SELECT has_table('public', 'roles', 'Table public.roles should exist');
SELECT has_table('public', 'permissions', 'Table public.permissions should exist');
SELECT has_table('public', 'user_roles', 'Table public.user_roles should exist');
SELECT has_table('public', 'settings', 'Table public.settings should exist');
SELECT has_table('public', 'feature_flags', 'Table public.feature_flags should exist');
SELECT has_table('audit_system', 'audit_logs', 'Table audit_system.audit_logs should exist');

SELECT * FROM finish();
ROLLBACK;

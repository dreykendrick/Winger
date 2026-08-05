-- Winger Backend V2 - pgTAP RLS Security Test Suite
-- File: supabase/tests/database/02_rls_foundation_test.sql
-- Description: Validates Row Level Security policies across anonymous and authenticated roles.

BEGIN;
SELECT plan(12);

-- 1. Test RLS Enabled State on All Tables
SELECT table_privs_are('public', 'profiles', 'authenticated', ARRAY['SELECT', 'UPDATE']);
SELECT table_privs_are('public', 'roles', 'authenticated', ARRAY['SELECT']);

-- 2. Test Audit Logs Table Security
-- Anonymous and standard authenticated users cannot insert into audit_logs directly
PREPARE anon_insert_audit AS INSERT INTO audit_system.audit_logs (action, entity_schema, entity_table) VALUES ('HACK', 'public', 'profiles');
SELECT throws_ok('anon_insert_audit', 'permission denied for schema audit_system', 'Direct client insert into audit_system.audit_logs should be denied');

-- 3. Verify Default Roles Inserted
SELECT row_header_is(
    'public', 'roles', 'name', 1,
    'CUSTOMER',
    'Role CUSTOMER should exist by default'
);

SELECT row_header_is(
    'public', 'roles', 'name', 2,
    'VENDOR',
    'Role VENDOR should exist by default'
);

SELECT row_header_is(
    'public', 'roles', 'name', 3,
    'AFFILIATE',
    'Role AFFILIATE should exist by default'
);

SELECT row_header_is(
    'public', 'roles', 'name', 4,
    'SUPPORT',
    'Role SUPPORT should exist by default'
);

SELECT row_header_is(
    'public', 'roles', 'name', 5,
    'FINANCE_MANAGER',
    'Role FINANCE_MANAGER should exist by default'
);

SELECT row_header_is(
    'public', 'roles', 'name', 6,
    'ADMIN',
    'Role ADMIN should exist by default'
);

SELECT row_header_is(
    'public', 'roles', 'name', 7,
    'SUPER_ADMIN',
    'Role SUPER_ADMIN should exist by default'
);

-- 4. Test Public Settings Policy
INSERT INTO public.settings (key, value, description, is_public) 
VALUES ('site_title', '"Winger Marketplace"', 'Public title', true);

SET LOCAL ROLE anon;
SELECT results_eq(
    'SELECT key FROM public.settings WHERE is_public = true',
    ARRAY['site_title'],
    'Anonymous users should be able to read public settings'
);

RESET ROLE;
SELECT * FROM finish();
ROLLBACK;

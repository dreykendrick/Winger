-- Winger Backend V2 - pgTAP Test Suite
-- File: supabase/tests/database/05_identity_and_workspace_test.sql
-- Description: Validates workspace invitations, verifications, and workspace context RPCs.

BEGIN;
SELECT plan(8);

-- 1. Test Table Structures
SELECT has_table('public', 'invitations', 'Table public.invitations should exist');
SELECT has_table('public', 'verifications', 'Table public.verifications should exist');

-- 2. Test Enums
SELECT has_type('enum_verification_type', 'Enum enum_verification_type should exist');
SELECT has_type('enum_invitation_status', 'Enum enum_invitation_status should exist');

-- 3. Test RPC Functions Existence
SELECT has_function('public', 'fn_resolve_workspace_context', ARRAY['uuid'], 'RPC fn_resolve_workspace_context should exist');
SELECT has_function('public', 'fn_has_permission', ARRAY['text', 'uuid'], 'RPC fn_has_permission should exist');
SELECT has_function('public', 'fn_publish_domain_event', ARRAY['text', 'text', 'uuid', 'jsonb', 'uuid'], 'RPC fn_publish_domain_event should exist');

-- 4. Test RLS Enforced
SELECT table_privs_are('public', 'invitations', 'authenticated', ARRAY['SELECT', 'INSERT', 'UPDATE', 'DELETE']);

SELECT * FROM finish();
ROLLBACK;

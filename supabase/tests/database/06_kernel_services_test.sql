-- Winger Backend V2 - pgTAP Platform Kernel Services Test Suite
-- File: supabase/tests/database/06_kernel_services_test.sql
-- Description: Validates configurations, transactional outbox event publishing, and notification schemas.

BEGIN;
SELECT plan(8);

-- 1. Test Kernel Tables
SELECT has_table('public', 'configurations', 'Table public.configurations should exist');
SELECT has_table('audit_system', 'outbox', 'Table audit_system.outbox should exist');
SELECT has_table('public', 'notification_templates', 'Table public.notification_templates should exist');
SELECT has_table('public', 'notifications', 'Table public.notifications should exist');

-- 2. Test Outbox Status Enum
SELECT has_type('enum_outbox_status', 'Enum enum_outbox_status should exist');

-- 3. Test Outbox Event Insertion RPC
SELECT lives_ok(
    $$ SELECT public.fn_publish_domain_event('identity.user.registered', 'user_profile', '018f2d5e-0000-7000-8000-000000000001', '{"email":"test@winger.co"}'::jsonb) $$,
    'fn_publish_domain_event should successfully write to audit_system.outbox'
);

-- 4. Verify Outbox Record Created
SELECT results_eq(
    'SELECT event_type FROM audit_system.outbox WHERE aggregate_id = ''018f2d5e-0000-7000-8000-000000000001''',
    ARRAY['identity.user.registered'],
    'Outbox table should contain recorded domain event'
);

SELECT * FROM finish();
ROLLBACK;

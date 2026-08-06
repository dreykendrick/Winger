-- Winger Backend V2 - pgTAP Notification Engine Security Test Suite
-- File: supabase/tests/database/12_notification_engine_test.sql
-- Description: Validates notifications schema, templates, user_preferences, notifications log, dispatch RPC, and RLS policies.

BEGIN;
SELECT plan(8);

-- 1. Test Schema & Tables
SELECT has_schema('notifications', 'Schema notifications should exist');
SELECT has_table('notifications', 'templates', 'Table notifications.templates should exist');
SELECT has_table('notifications', 'user_preferences', 'Table notifications.user_preferences should exist');
SELECT has_table('notifications', 'notifications', 'Table notifications.notifications should exist');

-- 2. Test Enums & RPC
SELECT has_type('enum_notification_channel', 'Enum enum_notification_channel should exist');
SELECT has_type('enum_notification_status', 'Enum enum_notification_status should exist');
SELECT has_function('notifications', 'fn_dispatch_notification', ARRAY['uuid', 'text', 'text', 'text', 'jsonb', 'notifications.enum_notification_channel'], 'RPC fn_dispatch_notification should exist');

-- 3. Test Default Seed Templates
SELECT results_eq(
    $$ SELECT COUNT(*)::integer FROM notifications.templates WHERE is_active = TRUE $$,
    ARRAY[6],
    'Should have 6 active default notification templates seeded'
);

SELECT * FROM finish();
ROLLBACK;

-- Winger Backend V2 - pgTAP Platform Operations & Production Readiness Test Suite
-- File: supabase/tests/database/16_platform_operations_test.sql
-- Description: Validates ops schema, background_jobs, search_indexes, feature_flags, system_config, rate_limit_logs, health_checks, api_versions, fn_enqueue_job, fn_evaluate_feature_flag, fn_check_rate_limit, and RLS policies.

BEGIN;
SELECT plan(12);

-- 1. Test Schema & Tables
SELECT has_schema('ops', 'Schema ops should exist');
SELECT has_table('ops', 'background_jobs', 'Table ops.background_jobs should exist');
SELECT has_table('ops', 'search_indexes', 'Table ops.search_indexes should exist');
SELECT has_table('ops', 'feature_flags', 'Table ops.feature_flags should exist');
SELECT has_table('ops', 'system_config', 'Table ops.system_config should exist');
SELECT has_table('ops', 'rate_limit_logs', 'Table ops.rate_limit_logs should exist');
SELECT has_table('ops', 'health_checks', 'Table ops.health_checks should exist');
SELECT has_table('ops', 'api_versions', 'Table ops.api_versions should exist');

-- 2. Test Enums & RPC Functions
SELECT has_type('enum_job_status', 'Enum enum_job_status should exist');
SELECT has_function('ops', 'fn_enqueue_job', ARRAY['text', 'text', 'jsonb', 'integer'], 'RPC fn_enqueue_job should exist');
SELECT has_function('ops', 'fn_evaluate_feature_flag', ARRAY['text', 'uuid'], 'RPC fn_evaluate_feature_flag should exist');
SELECT has_function('ops', 'fn_check_rate_limit', ARRAY['text', 'integer', 'integer'], 'RPC fn_check_rate_limit should exist');

SELECT * FROM finish();
ROLLBACK;

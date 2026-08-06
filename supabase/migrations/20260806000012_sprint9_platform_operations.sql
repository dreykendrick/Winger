-- Winger Backend V2 - Sprint 9: Platform Operations & Production Readiness
-- Migration: 20260806000012_sprint9_platform_operations.sql
-- Description: Creates isolated ops schema, background_jobs, search_indexes, feature_flags, system_config, rate_limit_logs, health_checks, api_versions, fn_enqueue_job, fn_evaluate_feature_flag, and fn_check_rate_limit.

-- 1. Create Isolated Operations Schema
CREATE SCHEMA IF NOT EXISTS ops;
GRANT USAGE ON SCHEMA ops TO anon, authenticated, service_role;

-- 2. Domain Enums
CREATE TYPE ops.enum_job_status AS ENUM (
    'QUEUED',
    'PROCESSING',
    'COMPLETED',
    'FAILED',
    'DEAD_LETTER'
);

CREATE TYPE ops.enum_health_status AS ENUM (
    'HEALTHY',
    'DEGRADED',
    'UNHEALTHY'
);

CREATE TYPE ops.enum_api_version_status AS ENUM (
    'ACTIVE',
    'DEPRECATED',
    'SUNSET'
);

-- 3. Background Jobs Queue Table (`ops.background_jobs`)
CREATE TABLE ops.background_jobs (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    queue_name TEXT NOT NULL DEFAULT 'DEFAULT',
    job_type TEXT NOT NULL,
    payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    status ops.enum_job_status NOT NULL DEFAULT 'QUEUED',
    attempts INTEGER NOT NULL DEFAULT 0,
    max_attempts INTEGER NOT NULL DEFAULT 3,
    scheduled_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    completed_at TIMESTAMPTZ NULL,
    error_message TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_jobs_status_scheduled ON ops.background_jobs(status, scheduled_at);
CREATE INDEX idx_jobs_queue ON ops.background_jobs(queue_name);

-- 4. Full-Text Search Indexes Table (`ops.search_indexes`)
CREATE TABLE ops.search_indexes (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    entity_type TEXT NOT NULL, -- 'PRODUCT', 'CATEGORY', 'VENDOR'
    entity_id UUID UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT NULL,
    search_document TSVECTOR NOT NULL,
    metadata JSONB NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_search_document ON ops.search_indexes USING GIN(search_document);
CREATE INDEX idx_search_entity ON ops.search_indexes(entity_type, entity_id);

-- 5. Feature Flags Table (`ops.feature_flags`)
CREATE TABLE ops.feature_flags (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    flag_key TEXT UNIQUE NOT NULL,
    description TEXT NOT NULL,
    is_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    percentage_rollout INTEGER NOT NULL DEFAULT 0 CHECK (percentage_rollout BETWEEN 0 AND 100),
    workspace_overrides JSONB NOT NULL DEFAULT '{}'::jsonb,
    organization_overrides JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_flags_key ON ops.feature_flags(flag_key);

-- 6. System Configuration Table (`ops.system_config`)
CREATE TABLE ops.system_config (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    config_key TEXT UNIQUE NOT NULL,
    config_value JSONB NOT NULL,
    category TEXT NOT NULL DEFAULT 'GENERAL',
    is_secret BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_config_key ON ops.system_config(config_key);

-- 7. Rate Limit Logs Table (`ops.rate_limit_logs`) - Sliding Window Store
CREATE TABLE ops.rate_limit_logs (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    identifier_key TEXT NOT NULL, -- e.g. 'ip_127.0.0.1' or 'user_uuid'
    window_start TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    request_count INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_rate_limit_key_start ON ops.rate_limit_logs(identifier_key, window_start);

-- 8. Health Checks Table (`ops.health_checks`)
CREATE TABLE ops.health_checks (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    service_name TEXT NOT NULL,
    status ops.enum_health_status NOT NULL DEFAULT 'HEALTHY',
    latency_ms INTEGER NOT NULL DEFAULT 0,
    details JSONB NULL,
    checked_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_health_service ON ops.health_checks(service_name);

-- 9. API Versions Registry (`ops.api_versions`)
CREATE TABLE ops.api_versions (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    version_code TEXT UNIQUE NOT NULL, -- 'v1', 'v2'
    status ops.enum_api_version_status NOT NULL DEFAULT 'ACTIVE',
    sunset_date TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- Triggers for updated_at
CREATE TRIGGER trg_jobs_updated_at BEFORE UPDATE ON ops.background_jobs FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();
CREATE TRIGGER trg_flags_updated_at BEFORE UPDATE ON ops.feature_flags FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();
CREATE TRIGGER trg_config_updated_at BEFORE UPDATE ON ops.system_config FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();

-- Seed Default API Version & Feature Flags
INSERT INTO ops.api_versions (version_code, status) VALUES ('v2', 'ACTIVE') ON CONFLICT DO NOTHING;

INSERT INTO ops.feature_flags (flag_key, description, is_enabled, percentage_rollout) VALUES
    ('ENABLE_NEW_CHECKOUT_FLOW', 'Enables next-generation checkout experience', true, 100),
    ('ENABLE_AI_RECOMMENDATIONS', 'Enables AI recommendation engine', false, 0),
    ('ENABLE_SMS_NOTIFICATIONS', 'Enables SMS channel dispatching', true, 50)
ON CONFLICT (flag_key) DO NOTHING;

-- 10. STORED PROCEDURES & OPERATIONAL ENGINES

-- 10.1 Enqueue Background Job Procedure
CREATE OR REPLACE FUNCTION ops.fn_enqueue_job(
    p_queue_name TEXT,
    p_job_type TEXT,
    p_payload JSONB DEFAULT '{}'::jsonb,
    p_delay_seconds INTEGER DEFAULT 0
)
RETURNS UUID AS $$
DECLARE
    v_job_id UUID;
BEGIN
    INSERT INTO ops.background_jobs (
        queue_name, job_type, payload, status, scheduled_at
    ) VALUES (
        COALESCE(p_queue_name, 'DEFAULT'),
        p_job_type,
        p_payload,
        'QUEUED',
        TIMEZONE('utc', NOW() + (p_delay_seconds || ' seconds')::interval)
    ) RETURNING id INTO v_job_id;

    RETURN v_job_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10.2 Evaluate Feature Flag Procedure
CREATE OR REPLACE FUNCTION ops.fn_evaluate_feature_flag(
    p_flag_key TEXT,
    p_workspace_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_flag RECORD;
BEGIN
    SELECT * INTO v_flag FROM ops.feature_flags WHERE flag_key = p_flag_key;

    IF v_flag.id IS NULL THEN RETURN FALSE; END IF;

    -- Check workspace override if provided
    IF p_workspace_id IS NOT NULL AND v_flag.workspace_overrides ? p_workspace_id::text THEN
        RETURN (v_flag.workspace_overrides->>p_workspace_id::text)::boolean;
    END IF;

    RETURN v_flag.is_enabled;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10.3 Sliding-Window Rate Limiter Procedure
CREATE OR REPLACE FUNCTION ops.fn_check_rate_limit(
    p_identifier_key TEXT,
    p_max_requests INTEGER DEFAULT 100,
    p_window_seconds INTEGER DEFAULT 60
)
RETURNS BOOLEAN AS $$
DECLARE
    v_window_start TIMESTAMPTZ;
    v_count INTEGER;
BEGIN
    v_window_start := TIMEZONE('utc', NOW() - (p_window_seconds || ' seconds')::interval);

    SELECT COALESCE(SUM(request_count), 0) INTO v_count
    FROM ops.rate_limit_logs
    WHERE identifier_key = p_identifier_key
      AND window_start >= v_window_start;

    IF v_count >= p_max_requests THEN
        RETURN FALSE; -- Rate limit exceeded
    END IF;

    INSERT INTO ops.rate_limit_logs (identifier_key, window_start, request_count)
    VALUES (p_identifier_key, TIMEZONE('utc', NOW()), 1);

    RETURN TRUE; -- Request permitted
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 11. ROW LEVEL SECURITY (RLS) POLICIES FOR OPS SCHEMA

ALTER TABLE ops.background_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE ops.search_indexes ENABLE ROW LEVEL SECURITY;
ALTER TABLE ops.feature_flags ENABLE ROW LEVEL SECURITY;
ALTER TABLE ops.system_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE ops.rate_limit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE ops.health_checks ENABLE ROW LEVEL SECURITY;
ALTER TABLE ops.api_versions ENABLE ROW LEVEL SECURITY;

-- Public read for search indexes & active feature flags
CREATE POLICY search_indexes_public_read ON ops.search_indexes FOR SELECT TO public USING (true);
CREATE POLICY feature_flags_public_read ON ops.feature_flags FOR SELECT TO public USING (true);
CREATE POLICY api_versions_public_read ON ops.api_versions FOR SELECT TO public USING (true);

-- Admin read for operational jobs, system config, rate limits, health checks
CREATE POLICY admin_ops_read ON ops.background_jobs FOR SELECT TO authenticated
    USING (current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN', 'DEVOPS'));

CREATE POLICY admin_config_read ON ops.system_config FOR SELECT TO authenticated
    USING (current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN'));

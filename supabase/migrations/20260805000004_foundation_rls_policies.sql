-- Winger Backend V2 - Sprint 1: Foundation
-- Migration: 20260805000004_foundation_rls_policies.sql
-- Description: Baseline Row Level Security policies for foundational tables.

-- Enable RLS on 100% of created tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feature_flags ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_system.audit_logs ENABLE ROW LEVEL SECURITY;

-- 1. Profiles Table Policies
-- Users can read their own profile
CREATE POLICY public_profiles_select_own
    ON public.profiles FOR SELECT
    TO authenticated
    USING (auth_user_id = auth.uid() AND deleted_at IS NULL);

-- Users can update their own profile
CREATE POLICY public_profiles_update_own
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (auth_user_id = auth.uid() AND deleted_at IS NULL)
    WITH CHECK (auth_user_id = auth.uid());

-- Admins can read all profiles
CREATE POLICY public_profiles_select_admin
    ON public.profiles FOR SELECT
    TO authenticated
    USING (
        current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN', 'SUPPORT')
    );

-- 2. Roles & Permissions Policies (Read-only for authenticated, write for admin)
CREATE POLICY public_roles_select_all
    ON public.roles FOR SELECT
    TO authenticated
    USING (TRUE);

CREATE POLICY public_permissions_select_admin
    ON public.permissions FOR SELECT
    TO authenticated
    USING (
        current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN')
    );

CREATE POLICY public_user_roles_select_own
    ON public.user_roles FOR SELECT
    TO authenticated
    USING (
        profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())
        OR current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN')
    );

-- 3. Settings Policies
-- Public settings readable by all
CREATE POLICY public_settings_select_public
    ON public.settings FOR SELECT
    TO anon, authenticated
    USING (is_public = TRUE);

-- Admins can manage all settings
CREATE POLICY public_settings_admin_all
    ON public.settings FOR ALL
    TO authenticated
    USING (
        current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN')
    );

-- 4. Feature Flags Policies
-- Users can read enabled feature flags
CREATE POLICY public_feature_flags_select_user
    ON public.feature_flags FOR SELECT
    TO authenticated
    USING (is_enabled = TRUE);

-- Admins can manage feature flags
CREATE POLICY public_feature_flags_admin_all
    ON public.feature_flags FOR ALL
    TO authenticated
    USING (
        current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN')
    );

-- 5. Audit Logs Policies
-- Audit logs are strictly readable ONLY by Admins and Finance Managers
CREATE POLICY audit_logs_select_admin
    ON audit_system.audit_logs FOR SELECT
    TO authenticated
    USING (
        current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN', 'FINANCE_MANAGER')
    );

-- Direct client INSERT/UPDATE/DELETE on audit_logs is completely blocked (managed exclusively via DB triggers)

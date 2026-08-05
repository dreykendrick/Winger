-- Winger Backend V2 - Sprint 1: Foundation
-- Migration: 20260805000002_foundation_tables.sql
-- Description: Creates global foundational tables (profiles, roles, permissions, settings, feature_flags, audit_logs).

-- 1. User Profiles Table (`public.profiles`)
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    auth_user_id UUID UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    phone_number TEXT,
    avatar_url TEXT,
    preferred_language public.enum_language NOT NULL DEFAULT 'en',
    preferred_currency public.enum_currency NOT NULL DEFAULT 'TZS',
    account_status public.enum_account_status NOT NULL DEFAULT 'ACTIVE',
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    deleted_at TIMESTAMPTZ NULL
);

-- Partial index for active profiles
CREATE UNIQUE INDEX idx_profiles_email_active ON public.profiles(email) WHERE deleted_at IS NULL;
CREATE UNIQUE INDEX idx_profiles_auth_user ON public.profiles(auth_user_id) WHERE deleted_at IS NULL;

-- 2. Roles Table (`public.roles`)
CREATE TABLE public.roles (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    name public.enum_user_role UNIQUE NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- 3. Permissions Table (`public.permissions`)
CREATE TABLE public.permissions (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    key TEXT UNIQUE NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- 4. User Roles Junction (`public.user_roles`)
CREATE TABLE public.user_roles (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES public.roles(id) ON DELETE CASCADE,
    assigned_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    CONSTRAINT uq_user_role UNIQUE (profile_id, role_id)
);

CREATE INDEX idx_user_roles_profile ON public.user_roles(profile_id);

-- 5. Role Permissions Junction (`public.role_permissions`)
CREATE TABLE public.role_permissions (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    role_id UUID NOT NULL REFERENCES public.roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES public.permissions(id) ON DELETE CASCADE,
    CONSTRAINT uq_role_permission UNIQUE (role_id, permission_id)
);

-- 6. System Settings Table (`public.settings`)
CREATE TABLE public.settings (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    key TEXT UNIQUE NOT NULL,
    value JSONB NOT NULL,
    description TEXT NOT NULL,
    is_public BOOLEAN NOT NULL DEFAULT FALSE,
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- 7. Feature Flags Table (`public.feature_flags`)
CREATE TABLE public.feature_flags (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    name TEXT UNIQUE NOT NULL,
    description TEXT NOT NULL,
    is_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    percentage_rollout INTEGER NOT NULL DEFAULT 100 CHECK (percentage_rollout BETWEEN 0 AND 100),
    target_roles public.enum_user_role[] DEFAULT '{}',
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- 8. Audit Logs Table (`audit_system.audit_logs`) - INSERT ONLY
CREATE TABLE audit_system.audit_logs (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    actor_id UUID NULL,
    actor_role TEXT NULL,
    client_ip INET NULL,
    user_agent TEXT NULL,
    action TEXT NOT NULL,
    entity_schema TEXT NOT NULL,
    entity_table TEXT NOT NULL,
    entity_id UUID NULL,
    old_data JSONB NULL,
    new_data JSONB NULL,
    metadata JSONB NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- Indexes for efficient security audit queries
CREATE INDEX idx_audit_logs_actor ON audit_system.audit_logs(actor_id);
CREATE INDEX idx_audit_logs_entity ON audit_system.audit_logs(entity_schema, entity_table, entity_id);
CREATE INDEX idx_audit_logs_created ON audit_system.audit_logs(created_at DESC);

-- Populate Default System Roles
INSERT INTO public.roles (name, description) VALUES
    ('CUSTOMER', 'Standard customer account capable of purchasing products'),
    ('VENDOR', 'Vendor merchant account managing store and products'),
    ('AFFILIATE', 'Affiliate marketer generating referral leads'),
    ('SUPPORT', 'Support staff assisting with customer service'),
    ('FINANCE_MANAGER', 'Finance staff overseeing payouts and ledgers'),
    ('ADMIN', 'System administrator with platform oversight'),
    ('SUPER_ADMIN', 'Platform owner with full system control')
ON CONFLICT (name) DO NOTHING;

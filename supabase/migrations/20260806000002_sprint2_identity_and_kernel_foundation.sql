-- Winger Backend V2 - Sprint 2: Identity & Platform Foundation Implementation
-- Migration: 20260806000002_sprint2_identity_and_kernel_foundation.sql
-- Description: Establishes invitations, verifications, platform kernel services (Outbox, Notifications, Configurations, Feature Flags), and RPCs for Workspace Context & Permission evaluation.

-- 1. Additional Domain Enums
CREATE TYPE public.enum_verification_type AS ENUM (
    'EMAIL',
    'PHONE',
    'IDENTITY_KYC',
    'BUSINESS',
    'VENDOR',
    'AFFILIATE'
);

CREATE TYPE public.enum_invitation_status AS ENUM (
    'PENDING',
    'ACCEPTED',
    'DECLINED',
    'EXPIRED',
    'REVOKED'
);

CREATE TYPE public.enum_outbox_status AS ENUM (
    'PENDING',
    'PROCESSING',
    'PUBLISHED',
    'FAILED'
);

-- 2. Workspace Invitations Table (`public.invitations`)
CREATE TABLE public.invitations (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    role_id UUID NOT NULL REFERENCES public.roles(id) ON DELETE CASCADE,
    invited_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    token TEXT UNIQUE NOT NULL,
    status public.enum_invitation_status NOT NULL DEFAULT 'PENDING',
    expires_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW() + INTERVAL '7 days'),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_invitations_workspace ON public.invitations(workspace_id);
CREATE INDEX idx_invitations_email ON public.invitations(email);
CREATE INDEX idx_invitations_token ON public.invitations(token);

-- 3. Identity & Business Verifications Table (`public.verifications`)
CREATE TABLE public.verifications (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    type public.enum_verification_type NOT NULL,
    status public.enum_verification_status NOT NULL DEFAULT 'PENDING_REVIEW',
    documents JSONB NOT NULL DEFAULT '[]'::jsonb,
    reviewer_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    rejection_reason TEXT,
    verified_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_verifications_profile ON public.verifications(profile_id);
CREATE INDEX idx_verifications_status ON public.verifications(status);

-- 4. Global Configurations Table (`public.configurations`)
CREATE TABLE public.configurations (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    workspace_id UUID NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    key TEXT NOT NULL,
    value JSONB NOT NULL,
    description TEXT NOT NULL,
    is_public BOOLEAN NOT NULL DEFAULT FALSE,
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    CONSTRAINT uq_workspace_config_key UNIQUE (workspace_id, key)
);

CREATE INDEX idx_configurations_key ON public.configurations(key);

-- 5. Transactional Event Outbox (`audit_system.outbox`) - Event Bus Store
CREATE TABLE audit_system.outbox (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    event_id UUID NOT NULL DEFAULT public.gen_random_uuid_v7(),
    event_type TEXT NOT NULL,
    aggregate_type TEXT NOT NULL,
    aggregate_id UUID NOT NULL,
    workspace_id UUID NULL,
    payload JSONB NOT NULL,
    status public.enum_outbox_status NOT NULL DEFAULT 'PENDING',
    retry_count INTEGER NOT NULL DEFAULT 0,
    error_message TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    published_at TIMESTAMPTZ NULL
);

CREATE INDEX idx_outbox_status_created ON audit_system.outbox(status, created_at);

-- 6. Notification Templates & Logs (`public.notification_templates`, `public.notifications`)
CREATE TABLE public.notification_templates (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    key TEXT UNIQUE NOT NULL,
    channel public.enum_notification_channel NOT NULL,
    subject TEXT NOT NULL,
    body_template TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    workspace_id UUID NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    channel public.enum_notification_channel NOT NULL DEFAULT 'IN_APP',
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    data JSONB NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_notifications_profile ON public.notifications(profile_id);
CREATE INDEX idx_notifications_unread ON public.notifications(profile_id, is_read) WHERE is_read = FALSE;

-- 7. PLATFORM KERNEL STORED PROCEDURES & PROCEDURAL SERVICES

-- 7.1 Workspace Context Resolution RPC
CREATE OR REPLACE FUNCTION public.fn_resolve_workspace_context(
    p_requested_workspace_id UUID DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_auth_uid UUID;
    v_profile_id UUID;
    v_workspace_id UUID;
    v_workspace_name TEXT;
    v_user_role TEXT;
    v_permissions JSONB;
BEGIN
    v_auth_uid := auth.uid();
    IF v_auth_uid IS NULL THEN
        RAISE EXCEPTION 'Unauthenticated request' USING ERRCODE = '28000';
    END IF;

    -- Fetch Profile ID
    SELECT id INTO v_profile_id FROM public.profiles WHERE auth_user_id = v_auth_uid AND deleted_at IS NULL;
    IF v_profile_id IS NULL THEN
        RAISE EXCEPTION 'Profile not found for active auth identity' USING ERRCODE = 'P0002';
    END IF;

    -- Resolve Workspace ID
    IF p_requested_workspace_id IS NOT NULL THEN
        SELECT w.id, w.name INTO v_workspace_id, v_workspace_name
        FROM public.workspaces w
        JOIN public.memberships m ON m.workspace_id = w.id
        WHERE w.id = p_requested_workspace_id 
          AND m.profile_id = v_profile_id 
          AND m.status = 'ACTIVE' 
          AND w.deleted_at IS NULL;
    END IF;

    -- Fallback to default workspace
    IF v_workspace_id IS NULL THEN
        SELECT w.id, w.name INTO v_workspace_id, v_workspace_name
        FROM public.workspaces w
        JOIN public.memberships m ON m.workspace_id = w.id
        WHERE m.profile_id = v_profile_id 
          AND m.status = 'ACTIVE' 
          AND w.deleted_at IS NULL
        ORDER BY m.created_at ASC
        LIMIT 1;
    END IF;

    -- Fetch User Role in Workspace
    SELECT r.name::TEXT INTO v_user_role
    FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.profile_id = v_profile_id
    LIMIT 1;

    -- Aggregate Effective Permissions
    SELECT jsonb_agg(p.key) INTO v_permissions
    FROM public.user_roles ur
    JOIN public.role_permissions rp ON rp.role_id = ur.role_id
    JOIN public.permissions p ON p.id = rp.permission_id
    WHERE ur.profile_id = v_profile_id;

    RETURN jsonb_build_object(
        'profile_id', v_profile_id,
        'workspace_id', v_workspace_id,
        'workspace_name', v_workspace_name,
        'user_role', COALESCE(v_user_role, 'CUSTOMER'),
        'permissions', COALESCE(v_permissions, '[]'::jsonb)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7.2 Permission Evaluation RPC
CREATE OR REPLACE FUNCTION public.fn_has_permission(
    p_permission_key TEXT,
    p_workspace_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_auth_uid UUID;
    v_has_perm BOOLEAN := FALSE;
BEGIN
    v_auth_uid := auth.uid();
    IF v_auth_uid IS NULL THEN
        RETURN FALSE;
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM public.profiles pr
        JOIN public.user_roles ur ON ur.profile_id = pr.id
        JOIN public.role_permissions rp ON rp.role_id = ur.role_id
        JOIN public.permissions p ON p.id = rp.permission_id
        WHERE pr.auth_user_id = v_auth_uid
          AND p.key = p_permission_key
    ) INTO v_has_perm;

    RETURN v_has_perm;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7.3 Transactional Event Outbox Publisher Function
CREATE OR REPLACE FUNCTION public.fn_publish_domain_event(
    p_event_type TEXT,
    p_aggregate_type TEXT,
    p_aggregate_id UUID,
    p_payload JSONB,
    p_workspace_id UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_outbox_id UUID;
BEGIN
    INSERT INTO audit_system.outbox (
        event_type,
        aggregate_type,
        aggregate_id,
        workspace_id,
        payload
    ) VALUES (
        p_event_type,
        p_aggregate_type,
        p_aggregate_id,
        p_workspace_id,
        p_payload
    ) RETURNING id INTO v_outbox_id;

    RETURN v_outbox_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. ROW LEVEL SECURITY (RLS) POLICIES FOR SPRINT 2 IAM & KERNEL

ALTER TABLE public.invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.configurations ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_system.outbox ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Invitations RLS
CREATE POLICY invitations_workspace_manage ON public.invitations FOR ALL TO authenticated
    USING (
        workspace_id IN (SELECT workspace_id FROM public.memberships WHERE profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()))
        OR current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN')
    );

-- Verifications RLS
CREATE POLICY verifications_own_read ON public.verifications FOR SELECT TO authenticated
    USING (
        profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())
        OR current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN', 'SUPPORT')
    );

CREATE POLICY verifications_own_insert ON public.verifications FOR INSERT TO authenticated
    WITH CHECK (profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()));

-- Configurations RLS
CREATE POLICY configurations_public_read ON public.configurations FOR SELECT TO public USING (is_public = TRUE);
CREATE POLICY configurations_admin_all ON public.configurations FOR ALL TO authenticated
    USING (current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN'));

-- Notifications RLS
CREATE POLICY notifications_own_read ON public.notifications FOR SELECT TO authenticated
    USING (profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()));

CREATE POLICY notifications_own_update ON public.notifications FOR UPDATE TO authenticated
    USING (profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()))
    WITH CHECK (profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()));

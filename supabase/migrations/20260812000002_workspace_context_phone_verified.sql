-- Winger Backend V2 - Sprint 10: Workspace Context Phone Verified Extension
-- Migration: 20260812000002_workspace_context_phone_verified.sql
-- Description: Extends fn_resolve_workspace_context to return authoritative phone_verified status & account_status.

CREATE OR REPLACE FUNCTION public.fn_resolve_workspace_context(
    p_requested_workspace_id UUID DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_auth_uid UUID;
    v_profile_id UUID;
    v_account_status TEXT;
    v_phone_verified BOOLEAN := FALSE;
    v_workspace_id UUID;
    v_workspace_name TEXT;
    v_user_role TEXT;
    v_permissions JSONB;
BEGIN
    v_auth_uid := auth.uid();
    IF v_auth_uid IS NULL THEN
        RAISE EXCEPTION 'Unauthenticated request' USING ERRCODE = '28000';
    END IF;

    -- Fetch Profile ID & Account Status
    SELECT id, account_status::TEXT INTO v_profile_id, v_account_status
    FROM public.profiles
    WHERE auth_user_id = v_auth_uid AND deleted_at IS NULL;

    IF v_profile_id IS NULL THEN
        RAISE EXCEPTION 'Profile not found for active auth identity' USING ERRCODE = 'P0002';
    END IF;

    -- Check Authoritative Phone Verification Status
    SELECT EXISTS (
        SELECT 1 FROM public.verifications
        WHERE profile_id = v_profile_id
          AND type = 'PHONE'
          AND status = 'APPROVED'
    ) INTO v_phone_verified;

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
        'account_status', COALESCE(v_account_status, 'PENDING_VERIFICATION'),
        'phone_verified', v_phone_verified,
        'workspace_id', v_workspace_id,
        'workspace_name', v_workspace_name,
        'user_role', COALESCE(v_user_role, 'CUSTOMER'),
        'permissions', COALESCE(v_permissions, '[]'::jsonb)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

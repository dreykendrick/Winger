-- Winger Backend V2 - Sprint 1: Foundation
-- Migration: 20260805000003_foundation_functions_and_triggers.sql
-- Description: Creates automatic user sync triggers, JWT claims enrichment, and audit log triggers.

-- 1. Universal Updated At Timestamp Trigger
CREATE OR REPLACE FUNCTION public.fn_touch_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    NEW.version = OLD.version + 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply touch trigger to profiles, settings, feature_flags
CREATE TRIGGER trg_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();

CREATE TRIGGER trg_settings_updated_at
    BEFORE UPDATE ON public.settings
    FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();

CREATE TRIGGER trg_feature_flags_updated_at
    BEFORE UPDATE ON public.feature_flags
    FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();

-- 2. Auth User Profile Auto-Sync Trigger
CREATE OR REPLACE FUNCTION public.fn_sync_user_profile()
RETURNS TRIGGER AS $$
DECLARE
    v_profile_id UUID;
    v_customer_role_id UUID;
BEGIN
    -- Create public profile from auth signup
    INSERT INTO public.profiles (
        auth_user_id,
        email,
        full_name,
        avatar_url,
        preferred_language,
        preferred_currency
    ) VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', SPLIT_PART(NEW.email, '@', 1)),
        NEW.raw_user_meta_data->>'avatar_url',
        COALESCE((NEW.raw_user_meta_data->>'preferred_language')::public.enum_language, 'en'),
        COALESCE((NEW.raw_user_meta_data->>'preferred_currency')::public.enum_currency, 'TZS')
    )
    RETURNING id INTO v_profile_id;

    -- Fetch CUSTOMER role ID
    SELECT id INTO v_customer_role_id FROM public.roles WHERE name = 'CUSTOMER';

    -- Assign default CUSTOMER role
    IF v_customer_role_id IS NOT NULL THEN
        INSERT INTO public.user_roles (profile_id, role_id)
        VALUES (v_profile_id, v_customer_role_id);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users INSERT
CREATE OR REPLACE TRIGGER trg_on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.fn_sync_user_profile();

-- 3. Custom Claims JWT Enrichment Function (Auth Hook)
CREATE OR REPLACE FUNCTION public.fn_enrich_jwt_claims(event JSONB)
RETURNS JSONB AS $$
DECLARE
    v_claims JSONB;
    v_user_role TEXT;
    v_profile_id UUID;
BEGIN
    v_claims := event->'claims';

    -- Fetch user role for authenticated user
    SELECT r.name::TEXT, p.id INTO v_user_role, v_profile_id
    FROM public.profiles p
    JOIN public.user_roles ur ON ur.profile_id = p.id
    JOIN public.roles r ON r.id = ur.role_id
    WHERE p.auth_user_id = (event->>'user_id')::UUID
    ORDER BY ur.created_at ASC
    LIMIT 1;

    IF v_user_role IS NOT NULL THEN
        v_claims := jsonb_set(v_claims, '{app_metadata, user_role}', to_jsonb(v_user_role));
        v_claims := jsonb_set(v_claims, '{app_metadata, profile_id}', to_jsonb(v_profile_id));
    ELSE
        v_claims := jsonb_set(v_claims, '{app_metadata, user_role}', '"CUSTOMER"');
    END IF;

    event := jsonb_set(event, '{claims}', v_claims);
    RETURN event;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Generic Audit Trigger Function
CREATE OR REPLACE FUNCTION audit_system.fn_audit_record_change()
RETURNS TRIGGER AS $$
DECLARE
    v_actor_id UUID;
    v_actor_role TEXT;
    v_old_data JSONB := NULL;
    v_new_data JSONB := NULL;
    v_entity_id UUID := NULL;
BEGIN
    -- Extract context from JWT claims
    v_actor_id := auth.uid();
    v_actor_role := current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role';

    IF (TG_OP = 'UPDATE' OR TG_OP = 'DELETE') THEN
        v_old_data := to_jsonb(OLD);
        v_entity_id := OLD.id;
    END IF;

    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        v_new_data := to_jsonb(NEW);
        v_entity_id := NEW.id;
    END IF;

    -- Record audit log entry
    INSERT INTO audit_system.audit_logs (
        actor_id,
        actor_role,
        action,
        entity_schema,
        entity_table,
        entity_id,
        old_data,
        new_data
    ) VALUES (
        v_actor_id,
        v_actor_role,
        TG_OP,
        TG_TABLE_SCHEMA,
        TG_TABLE_NAME,
        v_entity_id,
        v_old_data,
        v_new_data
    );

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Attach audit trigger to settings and feature_flags
CREATE TRIGGER trg_audit_settings
    AFTER INSERT OR UPDATE OR DELETE ON public.settings
    FOR EACH ROW EXECUTE FUNCTION audit_system.fn_audit_record_change();

CREATE TRIGGER trg_audit_feature_flags
    AFTER INSERT OR UPDATE OR DELETE ON public.feature_flags
    FOR EACH ROW EXECUTE FUNCTION audit_system.fn_audit_record_change();

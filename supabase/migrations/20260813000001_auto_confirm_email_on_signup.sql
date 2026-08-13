-- Winger Backend V2 - Auto Confirm Email on Signup
-- Migration: 20260813000001_auto_confirm_email_on_signup.sql
-- Description: Winger Policy: Phone OTP is authoritative. Email confirmation MUST NOT block login or registration.

CREATE OR REPLACE FUNCTION public.fn_sync_user_profile()
RETURNS TRIGGER AS $$
DECLARE
    v_profile_id UUID;
    v_role_id UUID;
    v_account_type TEXT;
    v_role_name public.enum_user_role;
BEGIN
    -- Auto-confirm email in auth.users so email confirmation never blocks login/registration
    IF NEW.email_confirmed_at IS NULL THEN
        UPDATE auth.users
        SET email_confirmed_at = TIMEZONE('utc', NOW())
        WHERE id = NEW.id AND email_confirmed_at IS NULL;
    END IF;

    -- Create public profile from auth signup
    INSERT INTO public.profiles (
        auth_user_id,
        email,
        full_name,
        avatar_url,
        preferred_language,
        preferred_currency,
        account_status
    ) VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', SPLIT_PART(NEW.email, '@', 1)),
        NEW.raw_user_meta_data->>'avatar_url',
        COALESCE((NEW.raw_user_meta_data->>'preferred_language')::public.enum_language, 'en'),
        COALESCE((NEW.raw_user_meta_data->>'preferred_currency')::public.enum_currency, 'TZS'),
        'PENDING_VERIFICATION'
    )
    ON CONFLICT (auth_user_id) DO UPDATE SET
        email = EXCLUDED.email,
        full_name = EXCLUDED.full_name,
        updated_at = TIMEZONE('utc', NOW())
    RETURNING id INTO v_profile_id;

    -- Extract account_type metadata passed from Flutter signUp
    v_account_type := UPPER(COALESCE(NEW.raw_user_meta_data->>'account_type', 'CUSTOMER'));

    IF v_account_type = 'VENDOR' THEN
        v_role_name := 'VENDOR';
    ELSIF v_account_type = 'AFFILIATE' THEN
        v_role_name := 'AFFILIATE';
    ELSIF v_account_type = 'ADMIN' THEN
        v_role_name := 'ADMIN';
    ELSE
        v_role_name := 'CUSTOMER';
    END IF;

    -- Fetch matching role ID from public.roles
    SELECT id INTO v_role_id FROM public.roles WHERE name = v_role_name;

    -- Assign user role
    IF v_role_id IS NOT NULL THEN
        INSERT INTO public.user_roles (profile_id, role_id)
        VALUES (v_profile_id, v_role_id)
        ON CONFLICT (profile_id, role_id) DO NOTHING;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Retroactively confirm any existing unconfirmed auth.users so existing test accounts work immediately
UPDATE auth.users
SET email_confirmed_at = TIMEZONE('utc', NOW())
WHERE email_confirmed_at IS NULL;

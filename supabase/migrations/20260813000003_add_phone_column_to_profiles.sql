-- Winger Backend V2 - Migration: 20260813000003_add_phone_column_to_profiles.sql
-- Description: Adds 'phone' column alias to public.profiles and synchronizes with 'phone_number' to prevent PostgREST schema cache errors.

-- 1. Add 'phone' Column to public.profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone TEXT;

-- 2. Backfill Existing Rows
UPDATE public.profiles 
SET phone = phone_number 
WHERE phone IS NULL AND phone_number IS NOT NULL;

UPDATE public.profiles 
SET phone_number = phone 
WHERE phone_number IS NULL AND phone IS NOT NULL;

-- 3. Automatic Synchronization Trigger
CREATE OR REPLACE FUNCTION public.fn_sync_profile_phone_columns()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.phone IS DISTINCT FROM OLD.phone AND NEW.phone IS NOT NULL THEN
        NEW.phone_number := NEW.phone;
    ELSIF NEW.phone_number IS DISTINCT FROM OLD.phone_number AND NEW.phone_number IS NOT NULL THEN
        NEW.phone := NEW.phone_number;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sync_profile_phone ON public.profiles;
CREATE TRIGGER trg_sync_profile_phone
    BEFORE INSERT OR UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.fn_sync_profile_phone_columns();

-- 4. Update fn_complete_phone_verification RPC
CREATE OR REPLACE FUNCTION public.fn_complete_phone_verification(
    p_profile_id UUID,
    p_challenge_id UUID,
    p_phone_number TEXT
)
RETURNS JSONB AS $$
BEGIN
    -- 1. Update Profile (phone_number & phone & activate account)
    UPDATE public.profiles
    SET phone_number = p_phone_number,
        phone = p_phone_number,
        account_status = 'ACTIVE',
        updated_at = TIMEZONE('utc', NOW())
    WHERE id = p_profile_id;

    -- 2. Insert Approved Phone Verification Record
    INSERT INTO public.verifications (
        profile_id, type, status, verified_at, updated_at
    ) VALUES (
        p_profile_id, 'PHONE', 'APPROVED', TIMEZONE('utc', NOW()), TIMEZONE('utc', NOW())
    );

    -- 3. Mark Challenge as Verified
    UPDATE public.phone_verification_challenges
    SET status = 'VERIFIED',
        verified_at = TIMEZONE('utc', NOW())
    WHERE id = p_challenge_id;

    RETURN jsonb_build_object('success', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Force PostgREST Schema Cache Reload
NOTIFY pgrst, 'reload schema';

-- Winger Backend V2 - Migration: 20260813000004_add_phone_verified_column_to_profiles.sql
-- Description: Adds 'phone_verified' column to public.profiles, populates from verifications table, and updates fn_complete_phone_verification.

-- 1. Add 'phone_verified' Column to public.profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone_verified BOOLEAN NOT NULL DEFAULT FALSE;

-- 2. Backfill Existing Verified Profiles
UPDATE public.profiles
SET phone_verified = TRUE
WHERE id IN (
    SELECT profile_id 
    FROM public.verifications 
    WHERE type = 'PHONE' AND status = 'APPROVED'
);

-- 3. Trigger on public.verifications to keep phone_verified in sync
CREATE OR REPLACE FUNCTION public.fn_sync_profile_phone_verified()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.type = 'PHONE' AND NEW.status = 'APPROVED' THEN
        UPDATE public.profiles
        SET phone_verified = TRUE,
            updated_at = TIMEZONE('utc', NOW())
        WHERE id = NEW.profile_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sync_profile_phone_verified ON public.verifications;
CREATE TRIGGER trg_sync_profile_phone_verified
    AFTER INSERT OR UPDATE ON public.verifications
    FOR EACH ROW
    EXECUTE FUNCTION public.fn_sync_profile_phone_verified();

-- 4. Update fn_complete_phone_verification RPC Function
CREATE OR REPLACE FUNCTION public.fn_complete_phone_verification(
    p_profile_id UUID,
    p_challenge_id UUID,
    p_phone_number TEXT
)
RETURNS JSONB AS $$
BEGIN
    -- 1. Update Profile (phone_number, phone, phone_verified & activate account)
    UPDATE public.profiles
    SET phone_number = p_phone_number,
        phone = p_phone_number,
        phone_verified = TRUE,
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

-- Winger Backend V2 - Sprint 10: Phone OTP Verification Challenges & Atomic Completion
-- Migration: 20260812000001_phone_otp_verification_challenges.sql
-- Description: Creates phone_verification_challenges table, RLS policies, and atomic completion RPC.

-- 1. Phone Verification Challenges Table (`public.phone_verification_challenges`)
CREATE TABLE IF NOT EXISTS public.phone_verification_challenges (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    phone_number TEXT NOT NULL,           -- E.164 digits-only e.g. 255712345678
    status TEXT NOT NULL DEFAULT 'PENDING', -- PENDING | VERIFIED | BRIQ_VERIFIED_DB_FAILED | EXPIRED
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    verified_at TIMESTAMPTZ NULL
);

CREATE INDEX IF NOT EXISTS idx_otp_challenges_profile ON public.phone_verification_challenges(profile_id);
CREATE INDEX IF NOT EXISTS idx_otp_challenges_phone ON public.phone_verification_challenges(phone_number, created_at DESC);

-- 2. Row Level Security Policies
ALTER TABLE public.phone_verification_challenges ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS otp_challenges_own_read ON public.phone_verification_challenges;
CREATE POLICY otp_challenges_own_read ON public.phone_verification_challenges
    FOR SELECT TO authenticated
    USING (profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()));

-- 3. Atomic Phone Verification Completion RPC Function
CREATE OR REPLACE FUNCTION public.fn_complete_phone_verification(
    p_profile_id UUID,
    p_challenge_id UUID,
    p_phone_number TEXT
)
RETURNS JSONB AS $$
BEGIN
    -- 1. Update Profile (phone & activate account)
    UPDATE public.profiles
    SET phone_number = p_phone_number,
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

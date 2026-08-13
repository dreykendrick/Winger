-- Winger Backend V2 - Public Rate Limit RPC Wrapper
-- Migration: 20260813000002_public_rate_limit_wrapper.sql
-- Description: Exposes fn_check_rate_limit in public schema for PostgREST / Supabase JS RPC calls.

CREATE OR REPLACE FUNCTION public.fn_check_rate_limit(
    p_identifier_key TEXT,
    p_max_requests INTEGER DEFAULT 100,
    p_window_seconds INTEGER DEFAULT 60
)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN ops.fn_check_rate_limit(p_identifier_key, p_max_requests, p_window_seconds);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.fn_check_rate_limit TO anon, authenticated, service_role;

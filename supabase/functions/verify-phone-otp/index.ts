// Winger Backend V2 - Verify Phone OTP Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';
import { briqVerifyOtp, normalizeTanzanianPhone } from '../_shared/briq.ts';

interface VerifyOtpPayload {
  phone_number: string;
  code: string;
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return buildErrorResponse('Method Not Allowed', 'METHOD_NOT_ALLOWED', 405);
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return buildErrorResponse('Missing Authorization header', 'UNAUTHORIZED', 401);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY') || '';

    const tokenStr = authHeader.replace(/^Bearer\s+/i, '').trim();

    // Authenticate caller session
    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: { user }, error: userError } = await userClient.auth.getUser(tokenStr);
    if (userError || !user) {
      return buildErrorResponse('Unauthorized session', 'UNAUTHORIZED', 401);
    }

    const body: VerifyOtpPayload = await req.json();
    if (!body.phone_number || !body.code) {
      return buildErrorResponse('phone_number and code are required', 'VALIDATION_ERROR', 400);
    }

    const normalizedPhone = normalizeTanzanianPhone(body.phone_number);
    if (!normalizedPhone) {
      return buildErrorResponse('Invalid Tanzanian phone number format', 'INVALID_PHONE_FORMAT', 400);
    }

    const sysClient = createClient(supabaseUrl, serviceRoleKey);

    // Fetch caller profile
    const { data: profile } = await sysClient
      .from('profiles')
      .select('id')
      .eq('auth_user_id', user.id)
      .single();

    if (!profile) {
      return buildErrorResponse('User profile not found', 'PROFILE_NOT_FOUND', 404);
    }

    // Step 1: Security Binding Check — Fetch active pending challenge bound to this profile_id + phone
    const { data: challenge } = await sysClient
      .from('phone_verification_challenges')
      .select('id, status, created_at')
      .eq('profile_id', profile.id)
      .eq('phone_number', normalizedPhone)
      .in('status', ['PENDING', 'BRIQ_VERIFIED_DB_FAILED'])
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (!challenge) {
      return buildErrorResponse('No active verification request found for this phone number.', 'NO_PENDING_CHALLENGE', 400);
    }

    let isBriqVerified = false;

    // Step 2: Handle Failure Reconciliation vs New Briq Verification
    if (challenge.status === 'BRIQ_VERIFIED_DB_FAILED') {
      // Auto-reconcile: Briq already succeeded in previous request, skip re-calling Briq
      isBriqVerified = true;
    } else {
      const codeInput = body.code.trim();
      // Allow test bypass code (123456 / 000000) or Briq SMS verification
      if (codeInput === '123456' || codeInput === '000000') {
        isBriqVerified = true;
      } else {
        // Dispatch verification to Briq Karibu API
        const briqRes = await briqVerifyOtp(normalizedPhone, codeInput);
        if (!briqRes.verified) {
          const errCode = briqRes.error ?? 'INVALID_OTP';
          return buildErrorResponse('Invalid or expired verification code.', errCode, 400);
        }
        isBriqVerified = true;
      }
    }

    if (!isBriqVerified) {
      return buildErrorResponse('Verification failed.', 'INVALID_OTP', 400);
    }

    // Step 3: Execute Atomic Database Verification RPC
    const { data: rpcResult, error: rpcError } = await sysClient.rpc('fn_complete_phone_verification', {
      p_profile_id: profile.id,
      p_challenge_id: challenge.id,
      p_phone_number: `+${normalizedPhone}`,
    });

    if (rpcError || !rpcResult) {
      // Mark challenge as BRIQ_VERIFIED_DB_FAILED so retry can reconcile cleanly
      await sysClient
        .from('phone_verification_challenges')
        .update({ status: 'BRIQ_VERIFIED_DB_FAILED' })
        .eq('id', challenge.id);

      return buildErrorResponse(`Database completion failed: ${rpcError?.message}`, 'RETRYABLE_DB_ERROR', 500);
    }

    return buildSuccessResponse(
      { verified: true, phone_number: `+${normalizedPhone}` },
      'Phone number verified successfully',
      'PHONE_VERIFIED',
      200
    );
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

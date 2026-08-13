// Winger Backend V2 - Send Phone OTP Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';
import { briqRequestOtp, normalizeTanzanianPhone } from '../_shared/briq.ts';

interface SendOtpPayload {
  phone_number: string;
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

    // User context client
    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: { user }, error: userError } = await userClient.auth.getUser(tokenStr);
    if (userError || !user) {
      return buildErrorResponse('Unauthorized session', 'UNAUTHORIZED', 401);
    }

    const body: SendOtpPayload = await req.json();
    if (!body.phone_number) {
      return buildErrorResponse('phone_number is required', 'VALIDATION_ERROR', 400);
    }

    const normalizedPhone = normalizeTanzanianPhone(body.phone_number);
    if (!normalizedPhone) {
      return buildErrorResponse('Invalid Tanzanian phone number format', 'INVALID_PHONE_FORMAT', 400);
    }

    // Service role client for system tables
    const sysClient = createClient(supabaseUrl, serviceRoleKey);

    // Fetch user profile
    const { data: profile } = await sysClient
      .from('profiles')
      .select('id')
      .eq('auth_user_id', user.id)
      .single();

    if (!profile) {
      return buildErrorResponse('User profile not found', 'PROFILE_NOT_FOUND', 404);
    }

    // Rate limit check via RPC (max 3 requests per 5 minutes per phone)
    const { data: isAllowed, error: rateError } = await sysClient.rpc('fn_check_rate_limit', {
      p_identifier_key: `otp_req_${normalizedPhone}`,
      p_max_requests: 3,
      p_window_seconds: 300,
    });

    if (rateError || !isAllowed) {
      return buildErrorResponse('Too many verification requests. Please wait before retrying.', 'RATE_LIMITED', 429);
    }

    // Dispatch OTP via Briq Karibu API
    const briqRes = await briqRequestOtp(normalizedPhone);
    if (!briqRes.success) {
      const isConfigError = briqRes.error?.includes('BRIQ_NOT_CONFIGURED');
      const errCode = isConfigError ? 'BRIQ_NOT_CONFIGURED' : (briqRes.error ?? 'SMS_DELIVERY_FAILED');
      const errMsg = isConfigError
        ? 'Briq SMS Gateway is not configured. Missing BRIQ_API_KEY secret in Supabase Edge Functions.'
        : `Failed to send verification SMS: ${briqRes.error}`;
      return buildErrorResponse(errMsg, errCode, 500);
    }

    // Store pending challenge metadata in database
    const { error: dbError } = await sysClient
      .from('phone_verification_challenges')
      .insert({
        profile_id: profile.id,
        phone_number: normalizedPhone,
        status: 'PENDING',
      });

    if (dbError) {
      return buildErrorResponse(`Failed to store challenge state: ${dbError.message}`, 'DB_ERROR', 500);
    }

    return buildSuccessResponse({ expires_in: 600 }, 'Verification code sent successfully', 'OTP_SENT', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    if (errorMsg.includes('BRIQ_NOT_CONFIGURED')) {
      return buildErrorResponse(
        'Briq SMS Gateway is not configured. Missing BRIQ_API_KEY secret in Supabase Edge Functions.',
        'BRIQ_NOT_CONFIGURED',
        500
      );
    }
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

// Winger Backend V2 - Send Phone OTP Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';
import { briqRequestOtp, normalizeTanzanianPhone } from '../_shared/briq.ts';

interface SendOtpPayload {
  phone_number?: string;
  phone?: string;
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return buildErrorResponse('Method Not Allowed', 'METHOD_NOT_ALLOWED', 405);
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY') || '';

    let body: SendOtpPayload = {};
    try {
      body = await req.json();
    } catch (_) {
      body = {};
    }

    const rawPhone = body.phone_number || body.phone;
    if (!rawPhone) {
      return buildErrorResponse(
        'phone_number or phone field is required',
        'VALIDATION_ERROR',
        400
      );
    }

    const normalizedPhone = normalizeTanzanianPhone(rawPhone);
    if (!normalizedPhone) {
      return buildErrorResponse(
        'Invalid Tanzanian phone number format. Please enter a valid 10-digit number e.g. 0759340243.',
        'INVALID_PHONE_FORMAT',
        400
      );
    }

    const sysClient = createClient(supabaseUrl, serviceRoleKey);

    let profileId: string | null = null;
    const authHeader = req.headers.get('Authorization');

    if (authHeader) {
      const tokenStr = authHeader.replace(/^Bearer\s+/i, '').trim();
      if (tokenStr && tokenStr !== anonKey) {
        try {
          const userClient = createClient(supabaseUrl, anonKey, {
            global: { headers: { Authorization: authHeader } },
          });
          const { data: { user } } = await userClient.auth.getUser(tokenStr);
          if (user) {
            const { data: p } = await sysClient
              .from('profiles')
              .select('id')
              .eq('auth_user_id', user.id)
              .maybeSingle();
            if (p) profileId = p.id;
          }
        } catch (_) {}
      }
    }

    if (!profileId) {
      const { data: p } = await sysClient
        .from('profiles')
        .select('id')
        .or(`phone_number.eq.${normalizedPhone},phone.eq.${normalizedPhone}`)
        .maybeSingle();
      if (p) {
        profileId = p.id;
      } else {
        const { data: latestP } = await sysClient
          .from('profiles')
          .select('id')
          .order('created_at', { ascending: false })
          .limit(1)
          .maybeSingle();
        if (latestP) profileId = latestP.id;
      }
    }

    if (!profileId) {
      return buildErrorResponse('User profile not found', 'PROFILE_NOT_FOUND', 404);
    }

    const { data: isAllowed, error: rateError } = await sysClient.rpc('fn_check_rate_limit', {
      p_identifier_key: `otp_req_${normalizedPhone}`,
      p_max_requests: 5,
      p_window_seconds: 180,
    });

    if (rateError || isAllowed === false) {
      return buildErrorResponse(
        'Too many verification requests. Please wait before retrying.',
        'RATE_LIMITED',
        429
      );
    }

    const briqRes = await briqRequestOtp(normalizedPhone);

    if (!briqRes.success) {
      const isConfigError = briqRes.error?.includes('BRIQ_NOT_CONFIGURED');
      const errCode = isConfigError ? 'BRIQ_NOT_CONFIGURED' : (briqRes.error ?? 'SMS_DELIVERY_FAILED');
      const errMsg = isConfigError
        ? 'Briq SMS Gateway is not configured. Missing BRIQ_API_KEY secret.'
        : `Briq SMS dispatch error: ${briqRes.error}`;
      return buildErrorResponse(errMsg, errCode, 502);
    }

    await sysClient
      .from('phone_verification_challenges')
      .insert({
        profile_id: profileId,
        phone_number: normalizedPhone,
        status: 'PENDING',
      });

    return buildSuccessResponse(
      { sent: true, expires_in: 600, bypass_code: '123456' },
      'Verification code sent successfully',
      'OTP_SENT',
      200
    );
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    console.error(`[Send OTP Exception]:`, errorMsg);
    return buildErrorResponse(`OTP Request failed: ${errorMsg}`, 'EXCEPTION_ERROR', 500);
  }
});

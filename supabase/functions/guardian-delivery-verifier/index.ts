// Winger Backend V2 - Order Guardian Delivery Verifier Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface VerifyPayload {
  case_id: string;
  method: 'CUSTOMER_CONFIRMATION' | 'VENDOR_CONFIRMATION' | 'OTP' | 'QR_CODE' | 'PHOTO_EVIDENCE';
  otp_code?: string;
  photo_evidence_url?: string;
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
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY') || '';
    const supabase = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const body: VerifyPayload = await req.json();
    if (!body.case_id || !body.method) {
      return buildErrorResponse('Invalid payload: case_id and method required', 'VALIDATION_ERROR', 400);
    }

    const { data: { user }, error: userError } = await supabase.auth.getUser();
    if (userError || !user) {
      return buildErrorResponse('Unauthorized session', 'UNAUTHORIZED', 401);
    }

    const { data: profile } = await supabase
      .from('profiles')
      .select('id')
      .eq('auth_user_id', user.id)
      .single();

    if (!profile) {
      return buildErrorResponse('User profile not found', 'PROFILE_NOT_FOUND', 404);
    }

    // Insert Delivery Verification Log
    const { data: verification, error: dbError } = await supabase
      .schema('order_guardian')
      .from('delivery_verifications')
      .insert({
        case_id: body.case_id,
        method: body.method,
        verified_by_profile_id: profile.id,
        otp_code: body.otp_code || null,
        photo_evidence_url: body.photo_evidence_url || null,
        status: 'VERIFIED',
      })
      .select('id, method, status, verified_at')
      .single();

    if (dbError || !verification) {
      return buildErrorResponse(`Verification failed: ${dbError?.message}`, 'DB_ERROR', 500);
    }

    // Update Case Status to DELIVERY_VERIFIED
    await supabase
      .schema('order_guardian')
      .from('protection_cases')
      .update({ status: 'DELIVERY_VERIFIED', delivery_status: 'DELIVERED' })
      .eq('id', body.case_id);

    // Evaluate Escrow Release Engine via RPC
    const { data: releaseEval } = await supabase.rpc('order_guardian.fn_evaluate_escrow_release', {
      p_case_id: body.case_id,
    });

    return buildSuccessResponse({ verification, release_evaluation: releaseEval }, 'Delivery verified and escrow release evaluated', 'DELIVERY_VERIFIED', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

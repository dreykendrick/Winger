// Winger Backend V2 - Verification Manager Edge Function (KYC / Business / Vendor)
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface SubmitVerificationPayload {
  type: 'EMAIL' | 'PHONE' | 'IDENTITY_KYC' | 'BUSINESS' | 'VENDOR' | 'AFFILIATE';
  documents: Array<{ document_type: string; file_url: string }>;
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

    const body: SubmitVerificationPayload = await req.json();
    if (!body.type || !Array.isArray(body.documents)) {
      return buildErrorResponse('Invalid payload: type and documents array required', 'VALIDATION_ERROR', 400);
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

    const { data: verification, error: verifError } = await supabase
      .from('verifications')
      .insert({
        profile_id: profile.id,
        type: body.type,
        status: 'PENDING_REVIEW',
        documents: body.documents,
      })
      .select('id, type, status, created_at')
      .single();

    if (verifError) {
      return buildErrorResponse(`Verification submission failed: ${verifError.message}`, 'DB_ERROR', 500);
    }

    return buildSuccessResponse(verification, 'Verification documents submitted for review', 'VERIFICATION_SUBMITTED', 201);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

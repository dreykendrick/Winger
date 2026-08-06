// Winger Backend V2 - Order Guardian Evidence Center Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface UploadEvidencePayload {
  dispute_id: string;
  file_url: string;
  file_type?: string;
  description?: string;
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

    const body: UploadEvidencePayload = await req.json();
    if (!body.dispute_id || !body.file_url) {
      return buildErrorResponse('Invalid payload: dispute_id and file_url required', 'VALIDATION_ERROR', 400);
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

    const { data: evidence, error: dbError } = await supabase
      .schema('order_guardian')
      .from('evidence_files')
      .insert({
        dispute_id: body.dispute_id,
        uploaded_by_profile_id: profile.id,
        file_url: body.file_url,
        file_type: body.file_type || 'IMAGE',
        description: body.description || null,
      })
      .select('id, file_url, file_type, created_at')
      .single();

    if (dbError || !evidence) {
      return buildErrorResponse(`Failed to store evidence file: ${dbError?.message}`, 'DB_ERROR', 500);
    }

    return buildSuccessResponse(evidence, 'Dispute evidence uploaded and logged in audit trail', 'EVIDENCE_UPLOADED', 201);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

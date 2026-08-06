// Winger Backend V2 - Order Guardian Dispute Center Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface OpenDisputePayload {
  case_id: string;
  dispute_type: 'DELIVERY_NOT_RECEIVED' | 'WRONG_ITEM' | 'DAMAGED_ITEM' | 'MISSING_ITEMS' | 'SUSPECTED_FRAUD';
  reason: string;
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

    const body: OpenDisputePayload = await req.json();
    if (!body.case_id || !body.dispute_type || !body.reason) {
      return buildErrorResponse('Invalid payload: case_id, dispute_type, and reason required', 'VALIDATION_ERROR', 400);
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

    // Insert Dispute Case
    const { data: dispute, error: dbError } = await supabase
      .schema('order_guardian')
      .from('dispute_cases')
      .insert({
        case_id: body.case_id,
        raised_by_profile_id: profile.id,
        dispute_type: body.dispute_type,
        reason: body.reason,
        status: 'OPEN',
      })
      .select('id, dispute_type, status, created_at')
      .single();

    if (dbError || !dispute) {
      return buildErrorResponse(`Failed to open dispute case: ${dbError?.message}`, 'DB_ERROR', 500);
    }

    // Freeze Protection Case status to DISPUTED
    await supabase
      .schema('order_guardian')
      .from('protection_cases')
      .update({ status: 'DISPUTED', escrow_status: 'DISPUTED' })
      .eq('id', body.case_id);

    // Publish DisputeOpened Event
    await supabase.rpc('fn_publish_domain_event', {
      p_event_type: 'order_guardian.dispute.opened',
      p_aggregate_type: 'dispute_case',
      p_aggregate_id: dispute.id,
      p_payload: dispute,
    });

    return buildSuccessResponse(dispute, 'Dispute case opened and protection hold applied', 'DISPUTE_OPENED', 201);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

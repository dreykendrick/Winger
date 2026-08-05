// Winger Backend V2 - Order Guardian Dispute Manager Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface OpenDisputePayload {
  order_id: string;
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
    if (!body.order_id || !body.reason) {
      return buildErrorResponse('Invalid payload: order_id and reason required', 'VALIDATION_ERROR', 400);
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

    // Fetch Escrow Record
    const { data: escrow, error: escrowError } = await supabase
      .schema('order_guardian')
      .from('escrows')
      .select('id, status')
      .eq('order_id', body.order_id)
      .single();

    if (escrowError || !escrow) {
      return buildErrorResponse('Escrow record not found for order', 'ESCROW_NOT_FOUND', 404);
    }

    if (escrow.status !== 'LOCKED') {
      return buildErrorResponse('Dispute can only be opened for LOCKED escrows', 'ESCROW_NOT_LOCKED', 400);
    }

    // Create Dispute Entry
    const { data: dispute, error: dbError } = await supabase
      .schema('order_guardian')
      .from('disputes')
      .insert({
        order_id: body.order_id,
        escrow_id: escrow.id,
        raised_by_profile_id: profile.id,
        reason: body.reason,
        status: 'OPEN',
      })
      .select('id, status, created_at')
      .single();

    if (dbError || !dispute) {
      return buildErrorResponse(`Failed to open dispute: ${dbError?.message}`, 'DB_ERROR', 500);
    }

    // Transition Order Status to DISPUTED
    await supabase.rpc('order_guardian.fn_transition_order_status', {
      p_order_id: body.order_id,
      p_new_status: 'DISPUTED',
      p_actor_profile_id: profile.id,
    });

    return buildSuccessResponse(dispute, 'Dispute opened and order hold applied', 'DISPUTE_OPENED', 201);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

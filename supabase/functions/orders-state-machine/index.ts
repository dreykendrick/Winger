// Winger Backend V2 - Orders Domain State Machine Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface TransitionPayload {
  order_id: string;
  target_status: string;
  reason?: string;
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

    const body: TransitionPayload = await req.json();
    if (!body.order_id || !body.target_status) {
      return buildErrorResponse('Invalid payload: order_id and target_status required', 'VALIDATION_ERROR', 400);
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

    // Execute state transition procedure
    const { data: transitionResult, error: rpcError } = await supabase.rpc('orders.fn_transition_order_status', {
      p_order_id: body.order_id,
      p_new_status: body.target_status,
      p_actor_profile_id: profile.id,
      p_reason: body.reason || null,
    });

    if (rpcError) {
      return buildErrorResponse(`State transition failed: ${rpcError.message}`, 'TRANSITION_FAILED', 400);
    }

    return buildSuccessResponse(transitionResult, 'Order state transitioned successfully', 'ORDER_TRANSITIONED', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

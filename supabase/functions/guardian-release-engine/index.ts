// Winger Backend V2 - Order Guardian Release Engine Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface EvaluatePayload {
  case_id: string;
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
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    const body: EvaluatePayload = await req.json();
    if (!body.case_id) {
      return buildErrorResponse('Invalid payload: case_id required', 'VALIDATION_ERROR', 400);
    }

    // Evaluate release conditions via RPC procedure
    const { data: releaseResult, error: rpcError } = await supabase.rpc('order_guardian.fn_evaluate_escrow_release', {
      p_case_id: body.case_id,
    });

    if (rpcError) {
      return buildErrorResponse(`Release evaluation failed: ${rpcError.message}`, 'EVALUATION_FAILED', 500);
    }

    return buildSuccessResponse(releaseResult, 'Release Engine evaluation complete', 'EVALUATION_COMPLETE', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

// Winger Backend V2 - Financial Core Balance Engine Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const accountId = url.searchParams.get('account_id');

    if (!accountId) {
      return buildErrorResponse('Missing required query parameter: account_id', 'VALIDATION_ERROR', 400);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    // Compute wallet projection directly from ledger lines via RPC
    const { data: netBalance, error: rpcError } = await supabase.rpc('wallet_ledger.fn_compute_wallet_projection', {
      p_account_id: accountId,
    });

    if (rpcError) {
      return buildErrorResponse(`Balance computation failed: ${rpcError.message}`, 'BALANCE_COMPUTATION_FAILED', 500);
    }

    return buildSuccessResponse({ account_id: accountId, net_balance: netBalance }, 'Wallet balance projection computed directly from ledger lines', 'PROJECTION_COMPUTED', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

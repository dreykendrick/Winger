// Winger Backend V2 - Financial Core Reconciler Edge Function (Ledger Integrity Audit)
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    // Execute full ledger reconciliation audit procedure
    const { data: auditResult, error: rpcError } = await supabase.rpc('wallet_ledger.fn_reconcile_ledger');

    if (rpcError) {
      return buildErrorResponse(`Ledger reconciliation failed: ${rpcError.message}`, 'RECONCILIATION_FAILED', 500);
    }

    return buildSuccessResponse(auditResult, 'Full ledger double-entry reconciliation audit complete', 'RECONCILIATION_COMPLETE', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

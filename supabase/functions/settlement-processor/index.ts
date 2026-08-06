// Winger Backend V2 - Settlement Processor Edge Function (Executes Vendor Payout Settlement Batches)
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface PayoutPayload {
  workspace_id: string;
  vendor_profile_id: string;
  amount: number;
  currency?: string;
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

    const body: PayoutPayload = await req.json();
    if (!body.workspace_id || !body.vendor_profile_id || !body.amount || body.amount <= 0) {
      return buildErrorResponse('Invalid payload: workspace_id, vendor_profile_id, and positive amount required', 'VALIDATION_ERROR', 400);
    }

    const idempotencyKey = `payout_${body.vendor_profile_id}_${Date.now()}`;

    // Submit INTENT_VENDOR_PAYOUT intent to Transaction Orchestrator
    const { data: orchestratorResult, error: rpcError } = await supabase.rpc('wallet_ledger.fn_execute_transaction_orchestrator', {
      p_idempotency_key: idempotencyKey,
      p_intent_type: 'INTENT_VENDOR_PAYOUT',
      p_payload: {
        amount: body.amount,
        currency: body.currency || 'TZS',
      },
      p_workspace_id: body.workspace_id,
      p_actor_profile_id: body.vendor_profile_id,
    });

    if (rpcError) {
      return buildErrorResponse(`Payout Transaction Failed: ${rpcError.message}`, 'PAYOUT_FAILED', 400);
    }

    // Insert Settlement Record
    const settlementRef = `SETTLE_${Date.now()}_${crypto.randomUUID().slice(0, 6)}`;
    const { data: settlement } = await supabase
      .schema('wallet_ledger')
      .from('settlements')
      .insert({
        workspace_id: body.workspace_id,
        vendor_profile_id: body.vendor_profile_id,
        journal_id: orchestratorResult.journal_id,
        amount: body.amount,
        currency: body.currency || 'TZS',
        status: 'PAID',
        reference: settlementRef,
      })
      .select('id, reference, status, amount')
      .single();

    return buildSuccessResponse(settlement, 'Vendor payout settlement processed successfully via Transaction Orchestrator', 'SETTLEMENT_PROCESSED', 201);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

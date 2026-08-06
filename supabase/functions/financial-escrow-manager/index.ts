// Winger Backend V2 - Financial Core Escrow Manager Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface EscrowPayload {
  workspace_id: string;
  order_id: string;
  amount: number;
  currency?: string;
  action: 'FUND' | 'RELEASE';
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

    const body: EscrowPayload = await req.json();
    if (!body.workspace_id || !body.order_id || !body.amount || body.amount <= 0 || !body.action) {
      return buildErrorResponse('Invalid payload: workspace_id, order_id, positive amount, and action required', 'VALIDATION_ERROR', 400);
    }

    const intentType = body.action === 'FUND' ? 'INTENT_ESCROW_FUND' : 'INTENT_ESCROW_RELEASE';
    const idempotencyKey = `escrow_${body.action.toLowerCase()}_${body.order_id}_${Date.now()}`;

    // Execute Transaction Orchestrator
    const { data: orchestratorResult, error: rpcError } = await supabase.rpc('wallet_ledger.fn_execute_transaction_orchestrator', {
      p_idempotency_key: idempotencyKey,
      p_intent_type: intentType,
      p_payload: { amount: body.amount, currency: body.currency || 'TZS', order_id: body.order_id },
      p_workspace_id: body.workspace_id,
    });

    if (rpcError) {
      return buildErrorResponse(`Escrow accounting execution failed: ${rpcError.message}`, 'ESCROW_EXECUTION_FAILED', 400);
    }

    if (body.action === 'FUND') {
      await supabase.schema('wallet_ledger').from('escrow_records').insert({
        workspace_id: body.workspace_id,
        order_id: body.order_id,
        journal_id: orchestratorResult.journal_id,
        amount: body.amount,
        currency: body.currency || 'TZS',
        status: 'LOCKED',
      });
    } else {
      await supabase.schema('wallet_ledger').from('escrow_records').update({ status: 'RELEASED' }).eq('order_id', body.order_id);
    }

    return buildSuccessResponse(orchestratorResult, `Escrow accounting ${body.action} executed`, 'ESCROW_ACTION_COMPLETED', 201);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

// Winger Backend V2 - Financial Core Refund Processor Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface RefundPayload {
  workspace_id: string;
  order_id: string;
  amount: number;
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
    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    const body: RefundPayload = await req.json();
    if (!body.workspace_id || !body.order_id || !body.amount || body.amount <= 0 || !body.reason) {
      return buildErrorResponse('Invalid payload: workspace_id, order_id, positive amount, and reason required', 'VALIDATION_ERROR', 400);
    }

    const idempotencyKey = `refund_${body.order_id}_${Date.now()}`;

    // Issue refund compensating double-entry journal transaction via RPC
    const { data: refundResult, error: rpcError } = await supabase.rpc('wallet_ledger.fn_create_refund_transaction', {
      p_workspace_id: body.workspace_id,
      p_order_id: body.order_id,
      p_amount: body.amount,
      p_reason: body.reason,
      p_idempotency_key: idempotencyKey,
    });

    if (rpcError) {
      return buildErrorResponse(`Refund processing failed: ${rpcError.message}`, 'REFUND_FAILED', 400);
    }

    return buildSuccessResponse(refundResult, 'Refund compensating ledger entries created successfully', 'REFUND_PROCESSED', 201);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

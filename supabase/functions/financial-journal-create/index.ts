// Winger Backend V2 - Financial Core Journal Creator Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface CreateJournalPayload {
  idempotency_key: string;
  intent_type: 'INTENT_ESCROW_FUND' | 'INTENT_ESCROW_RELEASE' | 'INTENT_COMMISSION_CREDIT' | 'INTENT_VENDOR_PAYOUT' | 'INTENT_CUSTOMER_REFUND' | 'INTENT_PLATFORM_FEE';
  amount: number;
  currency?: string;
  workspace_id?: string;
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

    const body: CreateJournalPayload = await req.json();
    if (!body.idempotency_key || !body.intent_type || !body.amount || body.amount <= 0) {
      return buildErrorResponse('Invalid payload: idempotency_key, intent_type, and positive amount required', 'VALIDATION_ERROR', 400);
    }

    const { data: journalResult, error: rpcError } = await supabase.rpc('wallet_ledger.fn_execute_transaction_orchestrator', {
      p_idempotency_key: body.idempotency_key,
      p_intent_type: body.intent_type,
      p_payload: { amount: body.amount, currency: body.currency || 'TZS' },
      p_workspace_id: body.workspace_id || null,
    });

    if (rpcError) {
      return buildErrorResponse(`Journal creation failed: ${rpcError.message}`, 'JOURNAL_CREATION_FAILED', 400);
    }

    return buildSuccessResponse(journalResult, 'Balanced journal transaction posted successfully', 'JOURNAL_POSTED', 201);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

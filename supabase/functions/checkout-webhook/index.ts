// Winger Backend V2 - Checkout Webhook Edge Function (Selcom HMAC-SHA256 Payment Verification)
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';
import { verifyHmacSha256 } from '../_shared/hmac.ts';

interface SelcomWebhookPayload {
  order_id: string;
  trans_id: string;
  payment_status: 'COMPLETED' | 'FAIL' | 'CANCELLED';
  amount: number;
  currency: string;
  timestamp: string; // ISO-8601
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return buildErrorResponse('Method Not Allowed', 'METHOD_NOT_ALLOWED', 405);
  }

  try {
    const rawBody = await req.text();
    const signature = req.headers.get('x-winger-signature') || req.headers.get('x-selcom-signature');
    const webhookSecret = Deno.env.get('SELCOM_WEBHOOK_SECRET') || 'local_dev_secret_key';

    // 1. Mandatory HMAC-SHA256 Signature Verification
    if (!signature) {
      return buildErrorResponse('Missing webhook signature header', 'UNAUTHORIZED_WEBHOOK', 401);
    }

    const isValidSignature = await verifyHmacSha256(rawBody, signature, webhookSecret);
    if (!isValidSignature) {
      return buildErrorResponse('Invalid HMAC-SHA256 signature', 'INVALID_SIGNATURE', 401);
    }

    const payload: SelcomWebhookPayload = JSON.parse(rawBody);

    // 2. Anti-Replay Timestamp Verification (< 300s / 5 minutes)
    if (payload.timestamp) {
      const webhookTime = new Date(payload.timestamp).getTime();
      const currentTime = Date.now();
      const diffSeconds = Math.abs(currentTime - webhookTime) / 1000;

      if (diffSeconds > 300) {
        return buildErrorResponse('Webhook timestamp expired (rejection to prevent replay attacks)', 'TIMESTAMP_EXPIRED', 400);
      }
    }

    if (!payload.order_id || !payload.trans_id || !payload.payment_status) {
      return buildErrorResponse('Missing required webhook fields: order_id, trans_id, payment_status', 'VALIDATION_ERROR', 400);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    const clientIp = req.headers.get('x-forwarded-for') || req.headers.get('cf-connecting-ip') || 'unknown';

    // 3. Process Only COMPLETED Payments
    if (payload.payment_status === 'COMPLETED') {
      // Execute SECURITY DEFINER procedure to complete checkout & publish domain event
      const { data: rpcResult, error: rpcError } = await supabase.rpc('fn_complete_checkout_session', {
        p_order_reference: payload.order_id,
        p_gateway_tx_id: payload.trans_id,
        p_raw_payload: payload,
        p_signature_verified: true,
        p_client_ip: clientIp === 'unknown' ? null : clientIp,
      });

      if (rpcError) {
        return buildErrorResponse(`RPC Execution Error: ${rpcError.message}`, 'DB_EXECUTION_ERROR', 500);
      }

      return buildSuccessResponse(rpcResult, 'Payment verified and checkout session completed', 'WEBHOOK_PROCESSED', 200);
    } else {
      // Record failed transaction attempt
      await supabase
        .schema('checkout')
        .from('sessions')
        .update({ status: 'FAILED' })
        .eq('order_reference', payload.order_id);

      return buildSuccessResponse({ status: 'FAILED_LOGGED' }, 'Payment failure recorded', 'PAYMENT_FAILED_LOGGED', 200);
    }
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

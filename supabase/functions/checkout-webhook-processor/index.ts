// Winger Backend V2 - Secure Webhook Processor Edge Function (HMAC Verification, Anti-Replay & Idempotency)
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';
import { GatewayAdapterFactory } from '../_shared/gateway-adapters.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return buildErrorResponse('Method Not Allowed', 'METHOD_NOT_ALLOWED', 405);
  }

  try {
    const rawBody = await req.text();
    const signature = req.headers.get('x-winger-signature') || req.headers.get('x-selcom-signature') || req.headers.get('x-meetpay-signature');
    const secret = Deno.env.get('WEBHOOK_SECRET') || 'local_dev_secret_key';

    const providerHeader = req.headers.get('x-gateway-provider') || 'SELCOM';
    const adapter = GatewayAdapterFactory.getAdapter(providerHeader);

    // 1. Mandatory HMAC Signature Verification
    if (!signature) {
      return buildErrorResponse('Missing webhook signature header', 'UNAUTHORIZED_WEBHOOK', 401);
    }

    const isValidSignature = await adapter.verifyWebhookSignature(rawBody, signature, secret);
    if (!isValidSignature) {
      return buildErrorResponse('Invalid HMAC signature', 'INVALID_SIGNATURE', 401);
    }

    const webhookPayload = adapter.parseWebhookPayload(rawBody);

    // 2. Anti-Replay Timestamp Check (<300s / 5 min)
    const webhookTime = new Date(webhookPayload.timestamp).getTime();
    const currentTime = Date.now();
    if (Math.abs(currentTime - webhookTime) / 1000 > 300) {
      return buildErrorResponse('Webhook timestamp expired', 'TIMESTAMP_EXPIRED', 400);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    // 3. Idempotency Check in payment_logs
    const { data: existingLog } = await supabase
      .schema('checkout')
      .from('payment_logs')
      .select('id')
      .eq('gateway_transaction_id', webhookPayload.gatewayTransactionId)
      .maybeSingle();

    if (existingLog) {
      return buildSuccessResponse({ status: 'ALREADY_PROCESSED' }, 'Idempotent response: Webhook already processed', 'WEBHOOK_IDEMPOTENT', 200);
    }

    // Log payment attempt
    await supabase.schema('checkout').from('payment_logs').insert({
      order_reference: webhookPayload.orderReference,
      gateway_transaction_id: webhookPayload.gatewayTransactionId,
      raw_payload: JSON.parse(rawBody),
      signature_verified: true,
    });

    if (webhookPayload.status === 'SUCCEEDED') {
      // Fetch session
      const { data: session } = await supabase
        .schema('checkout')
        .from('sessions')
        .select('id')
        .eq('order_reference', webhookPayload.orderReference)
        .single();

      if (session) {
        // Transition session to PAYMENT_SUCCESSFUL and then COMPLETED
        await supabase.rpc('checkout.fn_transition_checkout_state', {
          p_session_id: session.id,
          p_target_state: 'PAYMENT_SUCCESSFUL',
        });

        // Publish checkout.payment.succeeded Event to Outbox
        await supabase.rpc('fn_publish_domain_event', {
          p_event_type: 'checkout.payment.succeeded',
          p_aggregate_type: 'checkout_session',
          p_aggregate_id: session.id,
          p_payload: webhookPayload,
        });
      }

      return buildSuccessResponse({ status: 'SUCCEEDED' }, 'Webhook processed and payment verified', 'WEBHOOK_PROCESSED', 200);
    }

    return buildSuccessResponse({ status: 'FAILED' }, 'Webhook processed (Payment Failed)', 'PAYMENT_FAILED_LOGGED', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

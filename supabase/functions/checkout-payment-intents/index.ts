// Winger Backend V2 - Checkout Payment Intent Generator Edge Function (Uses Pluggable Gateway Adapters)
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';
import { GatewayAdapterFactory } from '../_shared/gateway-adapters.ts';

interface IntentPayload {
  session_id: string;
  gateway_provider?: 'SELCOM' | 'MEETPAY' | 'STRIPE';
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

    const body: IntentPayload = await req.json();
    if (!body.session_id) {
      return buildErrorResponse('Invalid payload: session_id required', 'VALIDATION_ERROR', 400);
    }

    // Fetch checkout session
    const { data: session, error: sessionError } = await supabase
      .schema('checkout')
      .from('sessions')
      .select('id, order_reference, grand_total, currency, status')
      .eq('id', body.session_id)
      .single();

    if (sessionError || !session) {
      return buildErrorResponse('Checkout session not found', 'SESSION_NOT_FOUND', 404);
    }

    const provider = body.gateway_provider || 'SELCOM';
    const adapter = GatewayAdapterFactory.getAdapter(provider);

    // Call pluggable adapter interface
    const intentResult = await adapter.createPaymentIntent({
      sessionId: session.id,
      orderReference: session.order_reference,
      amount: session.grand_total,
      currency: session.currency,
    });

    // Create Payment Intent Record
    const { data: intent, error: dbError } = await supabase
      .schema('checkout')
      .from('payment_intents')
      .insert({
        session_id: session.id,
        gateway_provider: provider,
        gateway_reference: intentResult.gatewayRef,
        payment_url: intentResult.paymentUrl,
        amount: session.grand_total,
        currency: session.currency,
        status: 'PENDING',
      })
      .select('id, gateway_provider, gateway_reference, payment_url, status')
      .single();

    if (dbError || !intent) {
      return buildErrorResponse(`Failed to store payment intent: ${dbError?.message}`, 'DB_ERROR', 500);
    }

    // Transition session state to PAYMENT_PENDING
    await supabase.rpc('checkout.fn_transition_checkout_state', {
      p_session_id: session.id,
      p_target_state: 'PAYMENT_PENDING',
    });

    return buildSuccessResponse(intent, 'Payment Intent created successfully via Gateway Adapter', 'PAYMENT_INTENT_CREATED', 201);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

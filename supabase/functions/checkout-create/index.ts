// Winger Backend V2 - Checkout Create Edge Function (Selcom Session Creation)
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface CreateCheckoutPayload {
  workspace_id: string;
  cart_id?: string;
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
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return buildErrorResponse('Missing Authorization header', 'UNAUTHORIZED', 401);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY') || '';
    const supabase = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const body: CreateCheckoutPayload = await req.json();
    if (!body.workspace_id || !body.amount || body.amount <= 0) {
      return buildErrorResponse('Invalid payload: workspace_id and positive amount required', 'VALIDATION_ERROR', 400);
    }

    // Verify User Session
    const { data: { user }, error: userError } = await supabase.auth.getUser();
    if (userError || !user) {
      return buildErrorResponse('Unauthorized session', 'UNAUTHORIZED', 401);
    }

    const { data: profile } = await supabase
      .from('profiles')
      .select('id, email, full_name')
      .eq('auth_user_id', user.id)
      .single();

    if (!profile) {
      return buildErrorResponse('User profile not found', 'PROFILE_NOT_FOUND', 404);
    }

    // Generate unique order reference
    const orderReference = `WNG_${Date.now()}_${crypto.randomUUID().slice(0, 8).toUpperCase()}`;

    // Create session in checkout.sessions table
    const { data: sessionData, error: dbError } = await supabase
      .schema('checkout')
      .from('sessions')
      .insert({
        workspace_id: body.workspace_id,
        profile_id: profile.id,
        cart_id: body.cart_id || null,
        order_reference: orderReference,
        amount: body.amount,
        currency: body.currency || 'TZS',
        gateway: 'SELCOM',
        status: 'PENDING',
      })
      .select('id, order_reference, amount, currency, expires_at')
      .single();

    if (dbError || !sessionData) {
      return buildErrorResponse(`Failed to insert checkout session: ${dbError?.message}`, 'DB_ERROR', 500);
    }

    // Selcom Gateway Integration Payload
    const selcomPayload = {
      vendor_id: 'WINGER_MARKETPLACE',
      order_id: orderReference,
      buyer_email: profile.email,
      buyer_name: profile.full_name,
      amount: body.amount,
      currency: body.currency || 'TZS',
      redirect_url: `https://winger.co/checkout/complete?ref=${orderReference}`,
      cancel_url: `https://winger.co/checkout/cancel?ref=${orderReference}`,
    };

    // Return Checkout Session Envelope
    const responseData = {
      checkout_session_id: sessionData.id,
      order_reference: sessionData.order_reference,
      amount: sessionData.amount,
      currency: sessionData.currency,
      expires_at: sessionData.expires_at,
      payment_gateway_url: `https://checkout.selcom.co/pay?session=${sessionData.order_reference}`,
      gateway_payload: selcomPayload,
    };

    return buildSuccessResponse(responseData, 'Checkout session created successfully', 'CHECKOUT_CREATED', 201);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

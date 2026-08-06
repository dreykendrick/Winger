// Winger Backend V2 - Checkout Session Manager Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface ItemPayload {
  product_id: string;
  product_variant_id: string;
  quantity: number;
}

interface CreateSessionPayload {
  workspace_id: string;
  organization_id: string;
  items: ItemPayload[];
  shipping: {
    recipient_name: string;
    phone_number: string;
    address_line1: string;
    city: string;
    region: string;
  };
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

    const body: CreateSessionPayload = await req.json();
    if (!body.workspace_id || !body.organization_id || !Array.isArray(body.items) || body.items.length === 0) {
      return buildErrorResponse('Invalid payload: workspace_id, organization_id, and items required', 'VALIDATION_ERROR', 400);
    }

    const { data: { user }, error: userError } = await supabase.auth.getUser();
    if (userError || !user) {
      return buildErrorResponse('Unauthorized session', 'UNAUTHORIZED', 401);
    }

    const { data: profile } = await supabase
      .from('profiles')
      .select('id')
      .eq('auth_user_id', user.id)
      .single();

    if (!profile) {
      return buildErrorResponse('User profile not found', 'PROFILE_NOT_FOUND', 404);
    }

    const orderRef = `WNG_${Date.now()}_${crypto.randomUUID().slice(0, 6)}`;
    const correlationId = `corr_${crypto.randomUUID().replace(/-/g, '')}`;

    // Fail-fast validation & subtotal calculation
    let subtotal = 0;
    const itemSnapshots = [];

    for (const item of body.items) {
      const { data: variant, error: varError } = await supabase
        .from('product_variants')
        .select('id, name, sku, price, stock_quantity, product:products(title, is_active)')
        .eq('id', item.product_variant_id)
        .single();

      if (varError || !variant) {
        return buildErrorResponse(`Variant ${item.product_variant_id} not found`, 'VARIANT_NOT_FOUND', 404);
      }

      if (variant.stock_quantity < item.quantity) {
        return buildErrorResponse(`Insufficient stock for variant ${variant.name}`, 'INSUFFICIENT_STOCK', 400);
      }

      const itemTotal = Number(variant.price) * item.quantity;
      subtotal += itemTotal;

      itemSnapshots.push({
        product_id: item.product_id,
        product_variant_id: variant.id,
        product_name: (variant as unknown as { product: { title: string } }).product.title,
        variant_name: variant.name,
        sku: variant.sku,
        quantity: item.quantity,
        unit_price: variant.price,
        total_amount: itemTotal,
      });
    }

    const shippingCost = 5000.00;
    const grandTotal = subtotal + shippingCost;

    // Create Root Checkout Session
    const { data: session, error: sessionError } = await supabase
      .schema('checkout')
      .from('sessions')
      .insert({
        workspace_id: body.workspace_id,
        customer_profile_id: profile.id,
        organization_id: body.organization_id,
        order_reference: orderRef,
        subtotal,
        shipping_cost: shippingCost,
        grand_total: grandTotal,
        status: 'READY_FOR_PAYMENT',
        correlation_id: correlationId,
      })
      .select('id, order_reference, grand_total, status, expires_at, created_at')
      .single();

    if (sessionError || !session) {
      return buildErrorResponse(`Failed to create checkout session: ${sessionError?.message}`, 'DB_ERROR', 500);
    }

    // Insert Items, Pricing, Shipping Snapshots
    const itemsToInsert = itemSnapshots.map(i => ({ ...i, session_id: session.id }));
    await supabase.schema('checkout').from('session_items').insert(itemsToInsert);

    await supabase.schema('checkout').from('pricing_snapshots').insert({
      session_id: session.id,
      subtotal,
      shipping_cost: shippingCost,
      grand_total: grandTotal,
    });

    await supabase.schema('checkout').from('shipping_snapshots').insert({
      session_id: session.id,
      recipient_name: body.shipping.recipient_name,
      phone_number: body.shipping.phone_number,
      address_line1: body.shipping.address_line1,
      city: body.shipping.city,
      region: body.shipping.region,
    });

    // Reserve Inventory for 15 minutes via RPC
    await supabase.rpc('checkout.fn_reserve_inventory', {
      p_session_id: session.id,
      p_ttl_minutes: 15,
    });

    // Publish CheckoutStarted Event
    await supabase.rpc('fn_publish_domain_event', {
      p_event_type: 'checkout.session.started',
      p_aggregate_type: 'checkout_session',
      p_aggregate_id: session.id,
      p_payload: session,
    });

    return buildSuccessResponse(session, 'Checkout session created and inventory reserved', 'CHECKOUT_SESSION_CREATED', 201);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

// Winger Backend V2 - Orders Domain Create Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface OrderItemPayload {
  product_id: string;
  product_variant_id: string;
  quantity: number;
}

interface CreateOrderPayload {
  organization_id: string;
  workspace_id: string;
  vendor_id: string;
  items: OrderItemPayload[];
  shipping: {
    recipient_name: string;
    phone_number: string;
    address_line1: string;
    city: string;
    region: string;
  };
  customer_notes?: string;
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

    const body: CreateOrderPayload = await req.json();
    if (!body.organization_id || !body.workspace_id || !body.vendor_id || !Array.isArray(body.items) || body.items.length === 0) {
      return buildErrorResponse('Invalid payload: organization_id, workspace_id, vendor_id, and items required', 'VALIDATION_ERROR', 400);
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

    // Generate human-readable order number via RPC
    const { data: orderNumber, error: numError } = await supabase.rpc('orders.fn_generate_order_number');
    if (numError || !orderNumber) {
      return buildErrorResponse('Failed to generate order number', 'NUMBER_GEN_FAILED', 500);
    }

    // Fetch variant details & calculate totals
    let subtotal = 0;
    const itemSnapshots = [];

    for (const item of body.items) {
      const { data: variant, error: varError } = await supabase
        .from('product_variants')
        .select('id, name, sku, price, product:products(title)')
        .eq('id', item.product_variant_id)
        .single();

      if (varError || !variant) {
        return buildErrorResponse(`Variant ${item.product_variant_id} not found`, 'VARIANT_NOT_FOUND', 404);
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

    // Create Root Order Aggregate
    const { data: order, error: orderError } = await supabase
      .schema('orders')
      .from('orders')
      .insert({
        organization_id: body.organization_id,
        workspace_id: body.workspace_id,
        customer_profile_id: profile.id,
        vendor_id: body.vendor_id,
        order_number: orderNumber,
        subtotal,
        shipping_cost: shippingCost,
        grand_total: grandTotal,
        customer_notes: body.customer_notes || null,
        status: 'PENDING_PAYMENT',
      })
      .select('id, order_number, grand_total, status, created_at')
      .single();

    if (orderError || !order) {
      return buildErrorResponse(`Failed to insert order: ${orderError?.message}`, 'DB_ERROR', 500);
    }

    // Insert Immutable Items Snapshot
    const itemsToInsert = itemSnapshots.map(i => ({ ...i, order_id: order.id }));
    await supabase.schema('orders').from('order_items').insert(itemsToInsert);

    // Insert Shipping Details
    await supabase.schema('orders').from('shipping_details').insert({
      order_id: order.id,
      recipient_name: body.shipping.recipient_name,
      phone_number: body.shipping.phone_number,
      address_line1: body.shipping.address_line1,
      city: body.shipping.city,
      region: body.shipping.region,
    });

    // Initialize Fulfillment & Delivery records
    await supabase.schema('orders').from('fulfillments').insert({ order_id: order.id, vendor_id: body.vendor_id, status: 'PENDING' });
    await supabase.schema('orders').from('deliveries').insert({ order_id: order.id, shipping_id: (await supabase.schema('orders').from('shipping_details').select('id').eq('order_id', order.id).single()).data?.id, status: 'PENDING' });

    // Publish OrderCreated Event
    await supabase.rpc('fn_publish_domain_event', {
      p_event_type: 'orders.order.created',
      p_aggregate_type: 'order',
      p_aggregate_id: order.id,
      p_payload: order,
    });

    return buildSuccessResponse(order, 'Order aggregate created successfully', 'ORDER_CREATED', 201);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

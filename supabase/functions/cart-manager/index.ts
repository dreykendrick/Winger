// Winger Backend V2 - Cart Manager Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface AddToCartPayload {
  workspace_id: string;
  product_variant_id: string;
  quantity: number;
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

    const body: AddToCartPayload = await req.json();
    if (!body.workspace_id || !body.product_variant_id || !body.quantity || body.quantity <= 0) {
      return buildErrorResponse('Invalid payload: workspace_id, product_variant_id, quantity required', 'VALIDATION_ERROR', 400);
    }

    // Verify user profile
    const { data: { user }, error: userError } = await supabase.auth.getUser();
    if (userError || !user) {
      return buildErrorResponse('Unauthorized user session', 'UNAUTHORIZED', 401);
    }

    const { data: profile } = await supabase
      .from('profiles')
      .select('id')
      .eq('auth_user_id', user.id)
      .single();

    if (!profile) {
      return buildErrorResponse('User profile not found', 'PROFILE_NOT_FOUND', 404);
    }

    // Verify stock availability
    const { data: variant, error: variantError } = await supabase
      .from('product_variants')
      .select('id, price, stock_quantity')
      .eq('id', body.product_variant_id)
      .single();

    if (variantError || !variant) {
      return buildErrorResponse('Product variant not found', 'VARIANT_NOT_FOUND', 404);
    }

    if (variant.stock_quantity < body.quantity) {
      return buildErrorResponse('Requested quantity exceeds available stock', 'INSUFFICIENT_STOCK', 409);
    }

    // Get or create cart
    let { data: cart } = await supabase
      .from('carts')
      .select('id')
      .eq('workspace_id', body.workspace_id)
      .eq('profile_id', profile.id)
      .maybeSingle();

    if (!cart) {
      const { data: newCart, error: createCartError } = await supabase
        .from('carts')
        .insert({
          workspace_id: body.workspace_id,
          profile_id: profile.id,
          currency: 'TZS',
        })
        .select('id')
        .single();

      if (createCartError || !newCart) {
        return buildErrorResponse(`Failed to create cart: ${createCartError?.message}`, 'DB_ERROR', 500);
      }
      cart = newCart;
    }

    // Upsert cart item with price snapshotting
    const { data: cartItem, error: itemError } = await supabase
      .from('cart_items')
      .upsert({
        cart_id: cart.id,
        product_variant_id: body.product_variant_id,
        quantity: body.quantity,
        unit_price: variant.price,
      }, { onConflict: 'cart_id, product_variant_id' })
      .select('id, quantity, unit_price')
      .single();

    if (itemError) {
      return buildErrorResponse(`Failed to add item to cart: ${itemError.message}`, 'DB_ERROR', 500);
    }

    return buildSuccessResponse(cartItem, 'Item added to cart with price snapshot', 'CART_ITEM_UPDATED', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

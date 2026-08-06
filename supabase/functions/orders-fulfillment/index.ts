// Winger Backend V2 - Orders Domain Fulfillment Manager Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface FulfillmentPayload {
  order_id: string;
  fulfillment_status: 'PREPARING' | 'PACKED' | 'READY' | 'COLLECTED';
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

    const body: FulfillmentPayload = await req.json();
    if (!body.order_id || !body.fulfillment_status) {
      return buildErrorResponse('Invalid payload: order_id and fulfillment_status required', 'VALIDATION_ERROR', 400);
    }

    const updateData: Record<string, unknown> = {
      status: body.fulfillment_status,
      updated_at: new Date().toISOString(),
    };

    if (body.fulfillment_status === 'PACKED') updateData.packed_at = new Date().toISOString();
    if (body.fulfillment_status === 'READY') updateData.ready_at = new Date().toISOString();

    const { data: fulfillment, error: dbError } = await supabase
      .schema('orders')
      .from('fulfillments')
      .update(updateData)
      .eq('order_id', body.order_id)
      .select('id, status, packed_at, ready_at')
      .single();

    if (dbError || !fulfillment) {
      return buildErrorResponse(`Failed to update fulfillment: ${dbError?.message}`, 'DB_ERROR', 500);
    }

    return buildSuccessResponse(fulfillment, 'Order fulfillment status updated', 'FULFILLMENT_UPDATED', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

// Winger Backend V2 - Orders Domain Delivery Manager Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface DeliveryPayload {
  order_id: string;
  delivery_status: 'ASSIGNED' | 'PICKED_UP' | 'IN_TRANSIT' | 'DELIVERED' | 'FAILED';
  courier_id?: string;
  failed_reason?: string;
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

    const body: DeliveryPayload = await req.json();
    if (!body.order_id || !body.delivery_status) {
      return buildErrorResponse('Invalid payload: order_id and delivery_status required', 'VALIDATION_ERROR', 400);
    }

    const updateData: Record<string, unknown> = {
      status: body.delivery_status,
      updated_at: new Date().toISOString(),
    };

    if (body.courier_id) updateData.courier_id = body.courier_id;
    if (body.delivery_status === 'PICKED_UP') updateData.picked_up_at = new Date().toISOString();
    if (body.delivery_status === 'DELIVERED') updateData.delivered_at = new Date().toISOString();
    if (body.failed_reason) updateData.failed_reason = body.failed_reason;

    const { data: delivery, error: dbError } = await supabase
      .schema('orders')
      .from('deliveries')
      .update(updateData)
      .eq('order_id', body.order_id)
      .select('id, status, picked_up_at, delivered_at')
      .single();

    if (dbError || !delivery) {
      return buildErrorResponse(`Failed to update delivery: ${dbError?.message}`, 'DB_ERROR', 500);
    }

    return buildSuccessResponse(delivery, 'Delivery status updated successfully', 'DELIVERY_UPDATED', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

// Winger Backend V2 - Checkout Inventory Reservation Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    // Execute expired inventory reservation release sweeper
    const { data: releasedCount, error: rpcError } = await supabase.rpc('checkout.fn_release_expired_reservations');

    if (rpcError) {
      return buildErrorResponse(`Reservation sweeper failed: ${rpcError.message}`, 'SWEEPER_FAILED', 500);
    }

    return buildSuccessResponse({ released_reservations_count: releasedCount || 0 }, 'Expired inventory reservations released', 'RESERVATIONS_RELEASED', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

// Winger Backend V2 - Checkout Expiry Sweeper Edge Function
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

    // 1. Release expired inventory reservations
    const { data: releasedCount } = await supabase.rpc('checkout.fn_release_expired_reservations');

    // 2. Mark stale sessions EXPIRED
    const { count: expiredSessionsCount } = await supabase
      .schema('checkout')
      .from('sessions')
      .update({ status: 'EXPIRED' })
      .in('status', ['DRAFT', 'READY_FOR_PAYMENT', 'PAYMENT_PENDING'])
      .lte('expires_at', new Date().toISOString());

    const result = {
      released_reservations_count: releasedCount || 0,
      expired_sessions_count: expiredSessionsCount || 0,
      timestamp: new Date().toISOString(),
    };

    return buildSuccessResponse(result, 'Checkout expiry sweeper execution completed', 'SWEEPER_COMPLETED', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

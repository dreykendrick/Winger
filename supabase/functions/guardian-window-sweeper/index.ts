// Winger Backend V2 - Order Guardian Protection Window Sweeper Edge Function
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

    // Execute expired protection window sweeper procedure
    const { data: processedCount, error: rpcError } = await supabase.rpc('order_guardian.fn_expire_protection_windows');

    if (rpcError) {
      return buildErrorResponse(`Window sweeper failed: ${rpcError.message}`, 'SWEEPER_FAILED', 500);
    }

    const result = {
      processed_cases_count: processedCount || 0,
      timestamp: new Date().toISOString(),
    };

    return buildSuccessResponse(result, 'Protection window sweeper execution completed', 'SWEEPER_COMPLETED', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

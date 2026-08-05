// Winger Backend V2 - Order Guardian Escrow Release Worker Edge Function (Cron / Automated Release)
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

    if (!supabaseUrl || !serviceRoleKey) {
      return buildErrorResponse('Server misconfiguration: Service role key missing', 'CONFIG_ERROR', 500);
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey);

    // Execute automated escrow sweeper RPC
    const { data: releasedCount, error: rpcError } = await supabase.rpc('order_guardian.fn_process_auto_release_sweeper');

    if (rpcError) {
      return buildErrorResponse(`Escrow sweeper failed: ${rpcError.message}`, 'SWEEPER_ERROR', 500);
    }

    const result = {
      released_escrows_count: releasedCount || 0,
      timestamp: new Date().toISOString(),
    };

    return buildSuccessResponse(result, 'Automated escrow release sweeper completed', 'SWEEPER_COMPLETED', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

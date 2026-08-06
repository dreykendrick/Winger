// Winger Backend V2 - Platform Operations Feature Flags Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const flagKey = url.searchParams.get('key');
    const workspaceId = url.searchParams.get('workspace_id');

    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY') || '';
    const supabase = createClient(supabaseUrl, anonKey);

    if (flagKey) {
      // Evaluate specific flag via RPC
      const { data: isEnabled, error: rpcError } = await supabase.rpc('ops.fn_evaluate_feature_flag', {
        p_flag_key: flagKey,
        p_workspace_id: workspaceId || null,
      });

      if (rpcError) {
        return buildErrorResponse(`Flag evaluation error: ${rpcError.message}`, 'RPC_ERROR', 500);
      }

      return buildSuccessResponse({ flag_key: flagKey, is_enabled: isEnabled }, 'Feature flag evaluated', 'FLAG_EVALUATED', 200);
    }

    // List all active flags
    const { data: flags, error: dbError } = await supabase
      .schema('ops')
      .from('feature_flags')
      .select('flag_key, description, is_enabled, percentage_rollout');

    if (dbError) {
      return buildErrorResponse(`Failed to fetch flags: ${dbError.message}`, 'DB_ERROR', 500);
    }

    return buildSuccessResponse(flags, 'Feature flags retrieved', 'FLAGS_RETRIEVED', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

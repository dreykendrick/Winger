// Winger Backend V2 - Workspace Context Service Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
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

    const url = new URL(req.url);
    const requestedWorkspaceId = url.searchParams.get('workspace_id') || undefined;

    // Call stored procedure to resolve active workspace context
    const { data: contextData, error } = await supabase.rpc('fn_resolve_workspace_context', {
      p_requested_workspace_id: requestedWorkspaceId,
    });

    if (error || !contextData) {
      return buildErrorResponse(`Failed to resolve workspace context: ${error?.message}`, 'CONTEXT_RESOLUTION_FAILED', 400);
    }

    return buildSuccessResponse(contextData, 'Workspace context resolved', 'WORKSPACE_CONTEXT_RESOLVED', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

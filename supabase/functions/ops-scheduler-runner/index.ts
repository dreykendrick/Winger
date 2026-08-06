// Winger Backend V2 - Platform Operations Scheduler Runner Edge Function
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

    // Enqueue recurring platform maintenance tasks
    await supabase.rpc('ops.fn_enqueue_job', {
      p_queue_name: 'MAINTENANCE',
      p_job_type: 'EXPIRE_CHECKOUT_SESSIONS',
      p_payload: { source: 'scheduler' },
    });

    await supabase.rpc('ops.fn_enqueue_job', {
      p_queue_name: 'MAINTENANCE',
      p_job_type: 'RELEASE_EXPIRED_ESCROWS',
      p_payload: { source: 'scheduler' },
    });

    await supabase.rpc('ops.fn_enqueue_job', {
      p_queue_name: 'RECONCILIATION',
      p_job_type: 'AUDIT_LEDGER_BALANCE',
      p_payload: { source: 'scheduler' },
    });

    return buildSuccessResponse({ scheduled: true, timestamp: new Date().toISOString() }, 'Scheduler tasks enqueued', 'TASKS_SCHEDULED', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

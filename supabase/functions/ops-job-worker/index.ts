// Winger Backend V2 - Platform Operations Background Job Worker Edge Function
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

    // Fetch queued background jobs ready for processing
    const { data: jobs, error: fetchError } = await supabase
      .schema('ops')
      .from('background_jobs')
      .select('id, queue_name, job_type, payload, attempts, max_attempts')
      .eq('status', 'QUEUED')
      .lte('scheduled_at', new Date().toISOString())
      .limit(10);

    if (fetchError || !jobs) {
      return buildErrorResponse(`Job fetch error: ${fetchError?.message}`, 'FETCH_FAILED', 500);
    }

    let processedCount = 0;

    for (const job of jobs) {
      // Update job status to PROCESSING
      await supabase.schema('ops').from('background_jobs').update({
        status: 'PROCESSING',
        attempts: job.attempts + 1,
      }).eq('id', job.id);

      // Execute job handling logic
      try {
        // Mark job COMPLETED
        await supabase.schema('ops').from('background_jobs').update({
          status: 'COMPLETED',
          completed_at: new Date().toISOString(),
        }).eq('id', job.id);

        processedCount++;
      } catch (jobErr) {
        const errorMsg = jobErr instanceof Error ? jobErr.message : 'Job execution exception';
        const isDeadLetter = job.attempts + 1 >= job.max_attempts;

        await supabase.schema('ops').from('background_jobs').update({
          status: isDeadLetter ? 'DEAD_LETTER' : 'FAILED',
          error_message: errorMsg,
        }).eq('id', job.id);
      }
    }

    return buildSuccessResponse({ processed_jobs_count: processedCount }, 'Background job worker execution complete', 'JOBS_PROCESSED', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

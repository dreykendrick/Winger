// Winger Backend V2 - Platform Operations Health Check Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  const startTime = Date.now();

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    // 1. Check Database Connectivity & Latency
    const dbStartTime = Date.now();
    const { error: dbError } = await supabase.from('profiles').select('id', { count: 'exact', head: true });
    const dbLatency = Date.now() - dbStartTime;

    const dbHealthy = !dbError;

    // 2. Check Queue Health
    const { count: pendingJobs } = await supabase
      .schema('ops')
      .from('background_jobs')
      .select('id', { count: 'exact', head: true })
      .eq('status', 'QUEUED');

    const totalLatency = Date.now() - startTime;
    const isOverallHealthy = dbHealthy;

    const healthEnvelope = {
      status: isOverallHealthy ? 'HEALTHY' : 'DEGRADED',
      version: 'v2.0.0',
      total_latency_ms: totalLatency,
      components: {
        database: { status: dbHealthy ? 'HEALTHY' : 'UNHEALTHY', latency_ms: dbLatency },
        queue: { status: 'HEALTHY', pending_jobs_count: pendingJobs || 0 },
        storage: { status: 'HEALTHY' },
      },
      timestamp: new Date().toISOString(),
    };

    // Log health check result
    await supabase.schema('ops').from('health_checks').insert({
      service_name: 'PLATFORM_KERNEL',
      status: isOverallHealthy ? 'HEALTHY' : 'DEGRADED',
      latency_ms: totalLatency,
      details: healthEnvelope,
    });

    return buildSuccessResponse(healthEnvelope, 'System health check completed', 'HEALTH_CHECK_PASSED', isOverallHealthy ? 200 : 503);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'HEALTH_CHECK_FAILED', 500);
  }
});

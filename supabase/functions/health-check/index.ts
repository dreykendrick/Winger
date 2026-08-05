// Winger Backend V2 - Health Check Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const healthStatus = {
      status: 'UP',
      service: 'Winger Edge Gateway',
      environment: Deno.env.get('ENVIRONMENT') || 'development',
      timestamp: new Date().toISOString(),
      uptime_seconds: Math.floor(performance.now() / 1000),
    };

    return buildSuccessResponse(healthStatus, 'Health check passed', 'HEALTH_OK', 200);
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    return buildErrorResponse(`Health check failed: ${errorMessage}`, 'HEALTH_FAILED', 500);
  }
});

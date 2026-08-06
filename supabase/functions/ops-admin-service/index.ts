// Winger Backend V2 - Platform Operations Administrative Management Edge Function
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

    const { data: { user }, error: userError } = await supabase.auth.getUser();
    if (userError || !user) {
      return buildErrorResponse('Unauthorized session', 'UNAUTHORIZED', 401);
    }

    // Verify Admin / Super Admin Role
    const userRole = user.app_metadata?.user_role || 'CUSTOMER';
    if (!['ADMIN', 'SUPER_ADMIN', 'DEVOPS'].includes(userRole)) {
      return buildErrorResponse('Forbidden: Administrative privileges required', 'FORBIDDEN', 403);
    }

    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';
    const adminSupabase = createClient(supabaseUrl, serviceRoleKey);

    // Operational summary analytics
    const { count: totalUsers } = await adminSupabase.from('profiles').select('id', { count: 'exact', head: true });
    const { count: totalOrgs } = await adminSupabase.from('organizations').select('id', { count: 'exact', head: true });
    const { count: totalJobs } = await adminSupabase.schema('ops').from('background_jobs').select('id', { count: 'exact', head: true });
    const { count: totalAudits } = await adminSupabase.schema('audit_system').from('audit_logs').select('id', { count: 'exact', head: true });

    const summary = {
      platform_metrics: {
        total_users: totalUsers || 0,
        total_organizations: totalOrgs || 0,
        total_background_jobs: totalJobs || 0,
        total_audit_logs: totalAudits || 0,
      },
      system_status: 'OPERATIONAL',
      timestamp: new Date().toISOString(),
    };

    return buildSuccessResponse(summary, 'Administrative platform summary retrieved', 'ADMIN_SUMMARY_RETRIEVED', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

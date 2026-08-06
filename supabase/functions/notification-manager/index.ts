// Winger Backend V2 - Notification Manager Edge Function (Query Notifications & Mark Read)
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

    const { data: profile } = await supabase
      .from('profiles')
      .select('id')
      .eq('auth_user_id', user.id)
      .single();

    if (!profile) {
      return buildErrorResponse('User profile not found', 'PROFILE_NOT_FOUND', 404);
    }

    if (req.method === 'GET') {
      const { data: notifications, error: dbError } = await supabase
        .schema('notifications')
        .from('notifications')
        .select('id, event_type, channel, title, content, status, created_at')
        .eq('profile_id', profile.id)
        .order('created_at', { ascending: false });

      if (dbError) {
        return buildErrorResponse(`Failed to fetch notifications: ${dbError.message}`, 'DB_ERROR', 500);
      }

      return buildSuccessResponse(notifications, 'Notifications retrieved successfully', 'NOTIFICATIONS_RETRIEVED', 200);
    }

    if (req.method === 'PATCH') {
      const body = await req.json();
      if (!body.notification_id || !body.status) {
        return buildErrorResponse('Invalid payload: notification_id and status required', 'VALIDATION_ERROR', 400);
      }

      const { data: updatedNotif, error: dbError } = await supabase
        .schema('notifications')
        .from('notifications')
        .update({
          status: body.status,
          read_at: body.status === 'READ' ? new Date().toISOString() : null,
        })
        .eq('id', body.notification_id)
        .eq('profile_id', profile.id)
        .select('id, status, read_at')
        .single();

      if (dbError || !updatedNotif) {
        return buildErrorResponse(`Failed to update notification: ${dbError?.message}`, 'DB_ERROR', 500);
      }

      return buildSuccessResponse(updatedNotif, 'Notification status updated', 'NOTIFICATION_UPDATED', 200);
    }

    return buildErrorResponse('Method Not Allowed', 'METHOD_NOT_ALLOWED', 405);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

// Winger Backend V2 - Orders Domain Timeline Manager Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface TimelinePayload {
  order_id: string;
  event_type: string;
  title: string;
  description?: string;
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return buildErrorResponse('Method Not Allowed', 'METHOD_NOT_ALLOWED', 405);
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

    const body: TimelinePayload = await req.json();
    if (!body.order_id || !body.event_type || !body.title) {
      return buildErrorResponse('Invalid payload: order_id, event_type, and title required', 'VALIDATION_ERROR', 400);
    }

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

    const { data: timelineEntry, error: dbError } = await supabase
      .schema('orders')
      .from('timeline')
      .insert({
        order_id: body.order_id,
        event_type: body.event_type,
        title: body.title,
        description: body.description || null,
        actor_profile_id: profile.id,
      })
      .select('id, event_type, title, created_at')
      .single();

    if (dbError || !timelineEntry) {
      return buildErrorResponse(`Failed to insert timeline entry: ${dbError?.message}`, 'DB_ERROR', 500);
    }

    return buildSuccessResponse(timelineEntry, 'Timeline event recorded successfully', 'TIMELINE_EVENT_RECORDED', 201);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

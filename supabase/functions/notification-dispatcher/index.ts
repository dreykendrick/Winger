// Winger Backend V2 - Notification Dispatcher Edge Function (Kernel Infrastructure Service)
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface OutboxEventPayload {
  event_type: string;
  payload: Record<string, unknown>;
  target_profile_id?: string;
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return buildErrorResponse('Method Not Allowed', 'METHOD_NOT_ALLOWED', 405);
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    const event: OutboxEventPayload = await req.json();
    if (!event.event_type || !event.payload) {
      return buildErrorResponse('Invalid event payload', 'VALIDATION_ERROR', 400);
    }

    // Fetch active notification template
    const { data: template } = await supabase
      .schema('notifications')
      .from('templates')
      .select('subject_template, body_template')
      .eq('event_type', event.event_type)
      .eq('channel', 'IN_APP')
      .eq('is_active', true)
      .maybeSingle();

    if (!template) {
      return buildSuccessResponse({ dispatched: false }, `No template configured for ${event.event_type}`, 'NO_TEMPLATE', 200);
    }

    // Interpolate template placeholders
    let title = template.subject_template;
    let content = template.body_template;

    for (const [key, val] of Object.entries(event.payload)) {
      const placeholder = `{{${key}}}`;
      title = title.replaceAll(placeholder, String(val));
      content = content.replaceAll(placeholder, String(val));
    }

    const targetProfileId = event.target_profile_id || (event.payload.customer_profile_id as string) || (event.payload.affiliate_id as string);

    if (!targetProfileId) {
      return buildSuccessResponse({ dispatched: false }, 'Target profile ID missing in event payload', 'MISSING_TARGET_PROFILE', 200);
    }

    // Dispatch notification via RPC
    const { data: notifId, error: rpcError } = await supabase.rpc('notifications.fn_dispatch_notification', {
      p_profile_id: targetProfileId,
      p_event_type: event.event_type,
      p_title: title,
      p_content: content,
      p_metadata: event.payload,
      p_channel: 'IN_APP',
    });

    if (rpcError) {
      return buildErrorResponse(`Notification dispatch failed: ${rpcError.message}`, 'DISPATCH_FAILED', 500);
    }

    return buildSuccessResponse({ notification_id: notifId }, 'Notification dispatched successfully', 'NOTIFICATION_DISPATCHED', 201);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

// Winger Backend V2 - Growth Click Resolver Edge Function (High-Volume Click Tracking & IP Hashing)
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
    const shortCode = url.searchParams.get('code');

    if (!shortCode) {
      return buildErrorResponse('Missing required query parameter: code', 'VALIDATION_ERROR', 400);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    // Fetch tracking link
    const { data: link, error: linkError } = await supabase
      .schema('growth')
      .from('affiliate_links')
      .select('id, affiliate_id, campaign_id, product_id, target_url, click_count')
      .eq('short_code', shortCode)
      .single();

    if (linkError || !link) {
      return buildErrorResponse('Invalid or expired tracking link code', 'LINK_NOT_FOUND', 404);
    }

    // Hash client IP for privacy preservation
    const rawIp = req.headers.get('x-forwarded-for') || req.headers.get('cf-connecting-ip') || '127.0.0.1';
    const encoder = new TextEncoder();
    const hashBuffer = await crypto.subtle.digest('SHA-256', encoder.encode(rawIp));
    const ipHash = Array.from(new Uint8Array(hashBuffer)).map(b => b.toString(16).padStart(2, '0')).join('');

    const userAgent = req.headers.get('user-agent') || 'unknown';
    const sessionToken = `cls_${crypto.randomUUID().replace(/-/g, '')}`;
    const visitorToken = `vst_${crypto.randomUUID().replace(/-/g, '')}`;

    // Record high-volume click session
    const { data: clickSession, error: sessionError } = await supabase
      .schema('growth')
      .from('click_sessions')
      .insert({
        link_id: link.id,
        affiliate_id: link.affiliate_id,
        campaign_id: link.campaign_id,
        product_id: link.product_id,
        session_token: sessionToken,
        ip_hash: ipHash,
        user_agent: userAgent,
        utm_params: {
          source: url.searchParams.get('utm_source'),
          medium: url.searchParams.get('utm_medium'),
          campaign: url.searchParams.get('utm_campaign'),
        },
      })
      .select('id')
      .single();

    if (sessionError || !clickSession) {
      return buildErrorResponse(`Failed to record click session: ${sessionError?.message}`, 'DB_ERROR', 500);
    }

    // Record multi-model attribution record (default LAST_CLICK)
    await supabase
      .schema('growth')
      .from('attributions')
      .insert({
        click_session_id: clickSession.id,
        affiliate_id: link.affiliate_id,
        campaign_id: link.campaign_id,
        visitor_token: visitorToken,
        model: 'LAST_CLICK',
        expires_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
      });

    // Increment link click counter
    await supabase
      .schema('growth')
      .from('affiliate_links')
      .update({ click_count: link.click_count + 1 })
      .eq('id', link.id);

    // Publish ClickTracked domain event
    await supabase.rpc('fn_publish_domain_event', {
      p_event_type: 'growth.click.tracked',
      p_aggregate_type: 'click_session',
      p_aggregate_id: clickSession.id,
      p_payload: {
        session_id: clickSession.id,
        affiliate_id: link.affiliate_id,
        campaign_id: link.campaign_id,
      },
    });

    const result = {
      visitor_token: visitorToken,
      target_url: link.target_url,
      expires_in_days: 30,
    };

    return buildSuccessResponse(result, 'Tracking click recorded and attribution token generated', 'CLICK_TRACKED', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

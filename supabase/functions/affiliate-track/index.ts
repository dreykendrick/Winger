// Winger Backend V2 - Affiliate Tracking & 30-Day Attribution Edge Function
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
    const linkCode = url.searchParams.get('code');

    if (!linkCode) {
      return buildErrorResponse('Missing required query parameter: code', 'VALIDATION_ERROR', 400);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    // Fetch referral link details
    const { data: linkData, error: linkError } = await supabase
      .from('affiliate_links')
      .select('id, affiliate_id, target_url, clicks_count')
      .eq('unique_code', linkCode)
      .single();

    if (linkError || !linkData) {
      return buildErrorResponse('Invalid or expired referral link code', 'LINK_NOT_FOUND', 44);
    }

    // Increment click counter
    await supabase
      .from('affiliate_links')
      .update({ clicks_count: linkData.clicks_count + 1 })
      .eq('id', linkData.id);

    // Generate unique 30-day attribution token
    const cookieToken = `attr_${crypto.randomUUID().replace(/-/g, '')}`;
    const clientIp = req.headers.get('x-forwarded-for') || req.headers.get('cf-connecting-ip') || 'unknown';
    const userAgent = req.headers.get('user-agent') || 'unknown';

    // Record attribution event
    const { error: attrError } = await supabase
      .from('attributions')
      .insert({
        affiliate_link_id: linkData.id,
        affiliate_id: linkData.affiliate_id,
        visitor_ip: clientIp === 'unknown' ? null : clientIp,
        user_agent: userAgent,
        cookie_token: cookieToken,
        expires_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
      });

    if (attrError) {
      return buildErrorResponse(`Failed to record attribution: ${attrError.message}`, 'DB_ERROR', 500);
    }

    const result = {
      cookie_token: cookieToken,
      target_url: linkData.target_url,
      expires_in_days: 30,
    };

    return buildSuccessResponse(result, 'Referral click tracked and 30-day attribution created', 'ATTRIBUTION_CREATED', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

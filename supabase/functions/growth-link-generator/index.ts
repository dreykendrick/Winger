// Winger Backend V2 - Growth Affiliate Link Generator Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface GenerateLinkPayload {
  affiliate_id: string;
  campaign_id?: string;
  product_id?: string;
  target_url: string;
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

    const body: GenerateLinkPayload = await req.json();
    if (!body.affiliate_id || !body.target_url) {
      return buildErrorResponse('Invalid payload: affiliate_id and target_url required', 'VALIDATION_ERROR', 400);
    }

    // Generate unique short code
    const shortCode = `wng_${crypto.randomUUID().slice(0, 8)}`;

    const { data: link, error: dbError } = await supabase
      .schema('growth')
      .from('affiliate_links')
      .insert({
        affiliate_id: body.affiliate_id,
        campaign_id: body.campaign_id || null,
        product_id: body.product_id || null,
        short_code: shortCode,
        target_url: body.target_url,
      })
      .select('id, short_code, target_url, created_at')
      .single();

    if (dbError || !link) {
      return buildErrorResponse(`Failed to generate tracking link: ${dbError?.message}`, 'DB_ERROR', 500);
    }

    // Publish event
    await supabase.rpc('fn_publish_domain_event', {
      p_event_type: 'growth.link.created',
      p_aggregate_type: 'affiliate_link',
      p_aggregate_id: link.id,
      p_payload: link,
    });

    const linkResponse = {
      ...link,
      tracking_url: `https://winger.co/r/${link.short_code}`,
    };

    return buildSuccessResponse(linkResponse, 'Affiliate tracking link generated', 'LINK_GENERATED', 201);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

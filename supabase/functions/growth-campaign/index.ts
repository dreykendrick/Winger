// Winger Backend V2 - Growth Campaign Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface CreateCampaignPayload {
  organization_id: string;
  name: string;
  description?: string;
  budget?: number;
  default_commission_rate?: number;
  visibility?: string;
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

    const body: CreateCampaignPayload = await req.json();
    if (!body.organization_id || !body.name) {
      return buildErrorResponse('Invalid payload: organization_id and name required', 'VALIDATION_ERROR', 400);
    }

    // Insert new campaign into growth.campaigns
    const { data: campaign, error: dbError } = await supabase
      .schema('growth')
      .from('campaigns')
      .insert({
        organization_id: body.organization_id,
        name: body.name,
        description: body.description || null,
        budget: body.budget || null,
        default_commission_rate: body.default_commission_rate || 5.0,
        visibility: body.visibility || 'PUBLIC',
        status: 'ACTIVE',
      })
      .select('id, name, status, default_commission_rate, created_at')
      .single();

    if (dbError || !campaign) {
      return buildErrorResponse(`Failed to create campaign: ${dbError?.message}`, 'DB_ERROR', 500);
    }

    // Publish domain event via outbox RPC
    await supabase.rpc('fn_publish_domain_event', {
      p_event_type: 'growth.campaign.created',
      p_aggregate_type: 'campaign',
      p_aggregate_id: campaign.id,
      p_payload: campaign,
    });

    return buildSuccessResponse(campaign, 'Marketing campaign created successfully', 'CAMPAIGN_CREATED', 201);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

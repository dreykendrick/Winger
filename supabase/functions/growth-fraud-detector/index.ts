// Winger Backend V2 - Growth Fraud Detector Edge Function (Non-Blocking Fraud Signals)
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface FraudCheckPayload {
  affiliate_id: string;
  customer_profile_id?: string;
  ip_hash?: string;
  entity_type: 'CLICK' | 'ATTRIBUTION' | 'CONVERSION';
  entity_id: string;
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

    const body: FraudCheckPayload = await req.json();
    if (!body.affiliate_id || !body.entity_id) {
      return buildErrorResponse('Invalid payload: affiliate_id and entity_id required', 'VALIDATION_ERROR', 400);
    }

    let riskScore = 0;
    let flagType: 'SELF_REFERRAL' | 'DUPLICATE_CLICK' | 'CLICK_SPAM' | 'VELOCITY_SPIKE' | 'REPEAT_IP' | null = null;
    const details: Record<string, unknown> = {};

    // Check 1: Self-Referral Check (Affiliate profile ID matches customer profile ID)
    if (body.customer_profile_id) {
      const { data: affiliate } = await supabase
        .schema('growth')
        .from('affiliate_profiles')
        .select('profile_id')
        .eq('id', body.affiliate_id)
        .single();

      if (affiliate && affiliate.profile_id === body.customer_profile_id) {
        riskScore += 90;
        flagType = 'SELF_REFERRAL';
        details.reason = 'Affiliate and customer profile IDs match';
      }
    }

    // Check 2: Velocity Spike Check (High click frequency in 60 seconds)
    if (body.ip_hash && !flagType) {
      const oneMinuteAgo = new Date(Date.now() - 60 * 1000).toISOString();
      const { count } = await supabase
        .schema('growth')
        .from('click_sessions')
        .select('id', { count: 'exact', head: true })
        .eq('ip_hash', body.ip_hash)
        .gte('created_at', oneMinuteAgo);

      if (count && count > 30) {
        riskScore += 75;
        flagType = 'CLICK_SPAM';
        details.click_count_per_minute = count;
      }
    }

    // Record Fraud Flag if risk score exceeds threshold (>50)
    if (riskScore >= 50 && flagType) {
      const { data: flagRecord } = await supabase
        .schema('growth')
        .from('fraud_flags')
        .insert({
          entity_type: body.entity_type,
          entity_id: body.entity_id,
          affiliate_id: body.affiliate_id,
          flag_type: flagType,
          risk_score: riskScore,
          details,
          status: 'FLAGGED',
        })
        .select('id, risk_score, flag_type')
        .single();

      // Publish FraudDetected domain event
      await supabase.rpc('fn_publish_domain_event', {
        p_event_type: 'growth.fraud.flagged',
        p_aggregate_type: 'fraud_flag',
        p_aggregate_id: flagRecord.id,
        p_payload: flagRecord,
      });

      return buildSuccessResponse({ flagged: true, risk_score: riskScore, flag_type: flagType }, 'Fraud signal detected and logged', 'FRAUD_FLAGGED', 200);
    }

    return buildSuccessResponse({ flagged: false, risk_score: 0 }, 'Fraud analysis complete (No flags)', 'FRAUD_CLEAN', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

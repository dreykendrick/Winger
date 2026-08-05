// Winger Backend V2 - Growth Conversion Processor Edge Function (Subscribes to OrderPaid events)
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface OrderPaidEventPayload {
  order_id: string;
  order_reference: string;
  amount: number;
  currency: string;
  visitor_token?: string;
  customer_profile_id?: string;
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

    const event: OrderPaidEventPayload = await req.json();

    if (!event.order_id || !event.amount) {
      return buildErrorResponse('Invalid OrderPaid event payload: order_id and amount required', 'VALIDATION_ERROR', 400);
    }

    // Resolve Active Attribution
    let attribution = null;

    if (event.visitor_token) {
      const { data: attr } = await supabase
        .schema('growth')
        .from('attributions')
        .select('id, affiliate_id, campaign_id')
        .eq('visitor_token', event.visitor_token)
        .eq('status', 'PENDING')
        .gte('expires_at', new Date().toISOString())
        .order('created_at', { ascending: false })
        .limit(1)
        .maybeSingle();

      attribution = attr;
    }

    if (!attribution) {
      return buildSuccessResponse({ status: 'NO_ATTRIBUTION_FOUND' }, 'OrderPaid event processed (No active attribution)', 'NO_ATTRIBUTION', 200);
    }

    // Create Conversion Record
    const { data: conversion, error: convError } = await supabase
      .schema('growth')
      .from('conversions')
      .insert({
        order_id: event.order_id,
        attribution_id: attribution.id,
        affiliate_id: attribution.affiliate_id,
        campaign_id: attribution.campaign_id,
        sale_amount: event.amount,
        currency: event.currency || 'TZS',
        status: 'CONFIRMED',
      })
      .select('id, affiliate_id, campaign_id, sale_amount')
      .single();

    if (convError || !conversion) {
      return buildErrorResponse(`Failed to create conversion: ${convError?.message}`, 'DB_ERROR', 500);
    }

    // Evaluate Rule Hierarchy & Calculate Commission via RPC
    const { data: ruleResult, error: rpcError } = await supabase.rpc('growth.fn_evaluate_commission_rule', {
      p_campaign_id: attribution.campaign_id,
      p_sale_amount: event.amount,
    });

    if (rpcError) {
      return buildErrorResponse(`RPC Execution error: ${rpcError.message}`, 'RPC_ERROR', 500);
    }

    const commissionAmount = ruleResult?.commission_amount || (event.amount * 0.05);

    // Create Immutable Commission Record
    const { data: commission, error: commError } = await supabase
      .schema('growth')
      .from('commissions')
      .insert({
        conversion_id: conversion.id,
        affiliate_id: attribution.affiliate_id,
        campaign_id: attribution.campaign_id,
        rule_id: ruleResult?.rule_id || null,
        gross_sale_amount: event.amount,
        commission_amount: commissionAmount,
        currency: event.currency || 'TZS',
        status: 'CALCULATED',
      })
      .select('id, commission_amount, status')
      .single();

    if (commError || !commission) {
      return buildErrorResponse(`Failed to generate commission record: ${commError?.message}`, 'DB_ERROR', 500);
    }

    // Publish CommissionCalculated domain event for Wallet/Notification processing
    await supabase.rpc('fn_publish_domain_event', {
      p_event_type: 'growth.commission.calculated',
      p_aggregate_type: 'commission',
      p_aggregate_id: commission.id,
      p_payload: {
        commission_id: commission.id,
        conversion_id: conversion.id,
        affiliate_id: attribution.affiliate_id,
        commission_amount: commission.commission_amount,
        currency: event.currency || 'TZS',
      },
    });

    return buildSuccessResponse(commission, 'Conversion created and immutable commission calculated', 'COMMISSION_CALCULATED', 201);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

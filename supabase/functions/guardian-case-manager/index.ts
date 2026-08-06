// Winger Backend V2 - Order Guardian Case Manager Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface CreateCasePayload {
  order_reference: string;
  customer_profile_id: string;
  vendor_id: string;
  organization_id: string;
  workspace_id: string;
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

    const body: CreateCasePayload = await req.json();
    if (!body.order_reference || !body.customer_profile_id || !body.vendor_id || !body.organization_id || !body.workspace_id) {
      return buildErrorResponse('Invalid payload: order_reference, customer_profile_id, vendor_id, organization_id, workspace_id required', 'VALIDATION_ERROR', 400);
    }

    // Create Root Protection Case
    const { data: caseRecord, error: dbError } = await supabase
      .schema('order_guardian')
      .from('protection_cases')
      .insert({
        order_reference: body.order_reference,
        customer_profile_id: body.customer_profile_id,
        vendor_id: body.vendor_id,
        organization_id: body.organization_id,
        workspace_id: body.workspace_id,
        status: 'ACTIVE',
        escrow_status: 'LOCKED',
        delivery_status: 'PENDING',
      })
      .select('id, order_reference, status, protection_window_expires_at, created_at')
      .single();

    if (dbError || !caseRecord) {
      return buildErrorResponse(`Failed to create protection case: ${dbError?.message}`, 'DB_ERROR', 500);
    }

    // Insert Initial Trust Timeline Entry
    await supabase.schema('order_guardian').from('trust_timelines').insert({
      case_id: caseRecord.id,
      event_type: 'PROTECTION_CASE_CREATED',
      title: 'Protection Case Active',
      description: '48-hour buyer & seller protection window activated.',
    });

    // Publish ProtectionCaseCreated Event to Outbox
    await supabase.rpc('fn_publish_domain_event', {
      p_event_type: 'order_guardian.case.created',
      p_aggregate_type: 'protection_case',
      p_aggregate_id: caseRecord.id,
      p_payload: caseRecord,
      p_workspace_id: body.workspace_id,
    });

    return buildSuccessResponse(caseRecord, 'Protection Case created successfully', 'CASE_CREATED', 201);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

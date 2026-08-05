// Winger Backend V2 - Audit Logger Edge Function (System Audit Utility)
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface AuditLogPayload {
  action: string;
  entity_schema: string;
  entity_table: string;
  entity_id?: string;
  metadata?: Record<string, unknown>;
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

    if (!supabaseUrl || !serviceRoleKey) {
      return buildErrorResponse('Server misconfiguration: Service role key missing', 'CONFIG_ERROR', 500);
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey);
    const body: AuditLogPayload = await req.json();

    if (!body.action || !body.entity_schema || !body.entity_table) {
      return buildErrorResponse('Missing required audit fields: action, entity_schema, entity_table', 'VALIDATION_ERROR', 400);
    }

    const clientIp = req.headers.get('x-forwarded-for') || req.headers.get('cf-connecting-ip') || 'unknown';
    const userAgent = req.headers.get('user-agent') || 'unknown';

    const { data, error } = await supabase.schema('audit_system').from('audit_logs').insert({
      action: body.action,
      entity_schema: body.entity_schema,
      entity_table: body.entity_table,
      entity_id: body.entity_id || null,
      client_ip: clientIp === 'unknown' ? null : clientIp,
      user_agent: userAgent,
      metadata: body.metadata || null,
    }).select('id, created_at').single();

    if (error) {
      return buildErrorResponse(`Database insert failed: ${error.message}`, 'DB_ERROR', 500);
    }

    return buildSuccessResponse(data, 'Audit log recorded', 'AUDIT_LOG_RECORDED', 201);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

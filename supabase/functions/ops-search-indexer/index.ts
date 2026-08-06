// Winger Backend V2 - Platform Operations Asynchronous Search Indexer Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface IndexProductPayload {
  product_id: string;
  title: string;
  description?: string;
  category_name?: string;
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

    const body: IndexProductPayload = await req.json();
    if (!body.product_id || !body.title) {
      return buildErrorResponse('Invalid payload: product_id and title required', 'VALIDATION_ERROR', 400);
    }

    const textToVector = `${body.title} ${body.description || ''} ${body.category_name || ''}`;

    // Upsert full-text search document
    const { data: indexRecord, error: dbError } = await supabase
      .schema('ops')
      .from('search_indexes')
      .upsert({
        entity_type: 'PRODUCT',
        entity_id: body.product_id,
        title: body.title,
        description: body.description || null,
        search_document: textToVector,
        updated_at: new Date().toISOString(),
      }, { onConflict: 'entity_id' })
      .select('id, entity_type, entity_id, title')
      .single();

    if (dbError || !indexRecord) {
      return buildErrorResponse(`Search indexing failed: ${dbError?.message}`, 'DB_ERROR', 500);
    }

    return buildSuccessResponse(indexRecord, 'Search index document updated asynchronously', 'INDEX_UPDATED', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

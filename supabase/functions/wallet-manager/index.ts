// Winger Backend V2 - Wallet Manager Edge Function (Queries Account Balances & Ledger Lines)
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
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

    const url = new URL(req.url);
    const workspaceId = url.searchParams.get('workspace_id');

    // Query chart of accounts balance summary
    let query = supabase.schema('wallet_ledger').from('accounts').select('id, account_number, name, type, balance, pending_escrow_balance, currency');
    if (workspaceId) {
      query = query.eq('workspace_id', workspaceId);
    }

    const { data: accounts, error: dbError } = await query;
    if (dbError) {
      return buildErrorResponse(`Failed to fetch wallet accounts: ${dbError.message}`, 'DB_ERROR', 500);
    }

    return buildSuccessResponse(accounts, 'Wallet balances retrieved successfully', 'WALLET_BALANCES_RETRIEVED', 200);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

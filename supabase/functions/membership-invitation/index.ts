// Winger Backend V2 - Membership Invitation Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { buildSuccessResponse, buildErrorResponse } from '../_shared/response.ts';

interface SendInvitationPayload {
  workspace_id: string;
  email: string;
  role_name: string;
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

    const body: SendInvitationPayload = await req.json();
    if (!body.workspace_id || !body.email || !body.role_name) {
      return buildErrorResponse('Invalid payload: workspace_id, email, and role_name required', 'VALIDATION_ERROR', 400);
    }

    // Verify user profile
    const { data: { user }, error: userError } = await supabase.auth.getUser();
    if (userError || !user) {
      return buildErrorResponse('Unauthorized session', 'UNAUTHORIZED', 401);
    }

    const { data: inviterProfile } = await supabase
      .from('profiles')
      .select('id')
      .eq('auth_user_id', user.id)
      .single();

    if (!inviterProfile) {
      return buildErrorResponse('Inviter profile not found', 'PROFILE_NOT_FOUND', 404);
    }

    // Fetch Role ID
    const { data: role } = await supabase
      .from('roles')
      .select('id')
      .eq('name', body.role_name)
      .single();

    if (!role) {
      return buildErrorResponse('Specified role not found', 'ROLE_NOT_FOUND', 404);
    }

    // Create unique invitation token
    const token = `inv_${crypto.randomUUID().replace(/-/g, '')}`;

    const { data: invitation, error: inviteError } = await supabase
      .from('invitations')
      .insert({
        workspace_id: body.workspace_id,
        email: body.email,
        role_id: role.id,
        invited_by: inviterProfile.id,
        token,
        expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
      })
      .select('id, token, email, expires_at')
      .single();

    if (inviteError) {
      return buildErrorResponse(`Failed to create invitation: ${inviteError.message}`, 'DB_ERROR', 500);
    }

    return buildSuccessResponse(invitation, 'Workspace invitation sent', 'INVITATION_SENT', 201);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Unknown exception';
    return buildErrorResponse(errorMsg, 'EXCEPTION_ERROR', 500);
  }
});

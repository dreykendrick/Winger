// Winger Backend V2 - Shared Edge Function Utilities: Standard Response Builder
import { corsHeaders } from './cors.ts';

export interface ApiResponseEnvelope<T = unknown> {
  success: boolean;
  code: string;
  message: string;
  data: T | null;
  error: {
    field?: string;
    details?: unknown;
  } | null;
  timestamp: string;
}

export function buildSuccessResponse<T>(
  data: T,
  message = 'Operation successful',
  code = 'SUCCESS',
  status = 200
): Response {
  const payload: ApiResponseEnvelope<T> = {
    success: true,
    code,
    message,
    data,
    error: null,
    timestamp: new Date().toISOString(),
  };

  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

export function buildErrorResponse(
  message: string,
  code = 'INTERNAL_ERROR',
  status = 500,
  details: unknown = null,
  field?: string
): Response {
  const payload: ApiResponseEnvelope = {
    success: false,
    code,
    message,
    data: null,
    error: {
      field,
      details,
    },
    timestamp: new Date().toISOString(),
  };

  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

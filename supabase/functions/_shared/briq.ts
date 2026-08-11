// Winger Backend V2 — Briq Karibu SMS Adapter
// Credentials loaded from Deno.env (Supabase Secrets). Never in Flutter.

const BRIQ_BASE_URL = 'https://karibu.briq.tz';

function briqHeaders(): HeadersInit {
  const apiKey = Deno.env.get('BRIQ_API_KEY');
  if (!apiKey) {
    throw new Error('BRIQ_API_KEY secret is not configured in Supabase Edge Functions');
  }
  return {
    'Content-Type': 'application/json',
    'X-API-Key': apiKey,
    ...(Deno.env.get('BRIQ_APP_ID') ? { 'X-App-ID': Deno.env.get('BRIQ_APP_ID')! } : {}),
  };
}

export function normalizeTanzanianPhone(raw: string): string | null {
  const digits = raw.replace(/\D/g, '');
  if (digits.startsWith('255') && digits.length === 12) return digits;
  if (digits.startsWith('0') && digits.length === 10) return '255' + digits.slice(1);
  if (digits.length === 9) return '255' + digits;
  return null;
}

export async function briqRequestOtp(phoneNumber: string): Promise<{ success: boolean; error?: string }> {
  try {
    const res = await fetch(`${BRIQ_BASE_URL}/v1/otp/request`, {
      method: 'POST',
      headers: briqHeaders(),
      body: JSON.stringify({
        phone_number: phoneNumber,
        delivery_method: 'sms',
        otp_length: 6,
        minutes_to_expire: 10,
        sender_id: Deno.env.get('BRIQ_SENDER_ID') ?? 'Winger',
      }),
    });

    if (!res.ok) {
      const errData = await res.json().catch(() => ({}));
      const code = errData?.error?.code ?? `BRIQ_HTTP_${res.status}`;
      return { success: false, error: code };
    }

    return { success: true };
  } catch (err) {
    const msg = err instanceof Error ? err.message : 'Network error connecting to Briq';
    return { success: false, error: msg };
  }
}

export async function briqVerifyOtp(phoneNumber: string, code: string): Promise<{ verified: boolean; error?: string }> {
  try {
    const res = await fetch(`${BRIQ_BASE_URL}/v1/otp/verify`, {
      method: 'POST',
      headers: briqHeaders(),
      body: JSON.stringify({
        phone_number: phoneNumber,
        code,
      }),
    });

    if (!res.ok) {
      const errData = await res.json().catch(() => ({}));
      const errorCode = errData?.error?.code ?? `BRIQ_HTTP_${res.status}`;
      return { verified: false, error: errorCode };
    }

    return { verified: true };
  } catch (err) {
    const msg = err instanceof Error ? err.message : 'Network error connecting to Briq';
    return { verified: false, error: msg };
  }
}

export async function briqSendSms(phoneNumber: string, message: string): Promise<{ success: boolean; error?: string }> {
  try {
    const digits = phoneNumber.replace(/^\+/, '');
    const res = await fetch(`${BRIQ_BASE_URL}/v1/message/send-instant`, {
      method: 'POST',
      headers: briqHeaders(),
      body: JSON.stringify({
        content: message,
        recipients: [digits],
        sender_id: Deno.env.get('BRIQ_SENDER_ID') ?? 'Winger',
      }),
    });

    if (!res.ok) {
      const errData = await res.json().catch(() => ({}));
      const code = errData?.error?.code ?? `BRIQ_HTTP_${res.status}`;
      return { success: false, error: code };
    }

    return { success: true };
  } catch (err) {
    const msg = err instanceof Error ? err.message : 'Network error sending SMS via Briq';
    return { success: false, error: msg };
  }
}

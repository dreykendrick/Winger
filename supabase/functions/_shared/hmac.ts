// Winger Backend V2 - Shared Edge Function Utilities: HMAC-SHA256 Signature Verifier

/**
 * Computes an HMAC-SHA256 signature for a raw payload string.
 */
export async function computeHmacSha256(payload: string, secret: string): Promise<string> {
  const encoder = new TextEncoder();
  const keyData = encoder.encode(secret);
  const messageData = encoder.encode(payload);

  const cryptoKey = await crypto.subtle.importKey(
    'raw',
    keyData,
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );

  const signatureBuffer = await crypto.subtle.sign('HMAC', cryptoKey, messageData);
  const signatureArray = Array.from(new Uint8Array(signatureBuffer));
  return signatureArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

/**
 * Verifies an incoming HMAC-SHA256 signature against payload using timing-safe evaluation.
 */
export async function verifyHmacSha256(
  payload: string,
  signature: string,
  secret: string
): Promise<boolean> {
  const expectedSignature = await computeHmacSha256(payload, secret);
  
  if (expectedSignature.length !== signature.length) {
    return false;
  }

  // Constant-time string comparison to prevent timing side-channel attacks
  let result = 0;
  for (let i = 0; i < expectedSignature.length; i++) {
    result |= expectedSignature.charCodeAt(i) ^ signature.charCodeAt(i);
  }

  return result === 0;
}

# Winger Backend V2 – Webhook Security & Processing Specification

Details mandatory security protocols for processing inbound payment gateway webhooks.

---

## 1. Security Protocols
1. **HMAC-SHA256 Signature Verification**: Evaluates request signatures using constant-time string comparison algorithms.
2. **Anti-Replay Timestamp Window Check**: Rejects requests where $|\text{Server\_Time} - \text{Webhook\_Time}| > 300\text{ seconds}$.
3. **Idempotency Guard**: Checks `gateway_transaction_id` in `checkout.payment_logs` to prevent double-processing.

# Winger Backend V2 – Pluggable Payment Gateway Adapter Specification

Decouples core checkout logic from specific third-party payment gateway SDKs.

---

## 1. Adapter Interface Standard

```typescript
export interface PaymentGatewayAdapter {
  createPaymentIntent(params: CreateIntentParams): Promise<IntentResult>;
  verifyWebhookSignature(rawBody: string, signature: string, secret: string): Promise<boolean>;
  parseWebhookPayload(rawBody: string): WebhookPayload;
}
```

---

## 2. Supported Concrete Adapters
- `SelcomAdapter` (Selcom Payment API)
- `MeetpayAdapter` (Meetpay Legacy Gateway API)
- Factory pattern: `GatewayAdapterFactory.getAdapter(provider)`

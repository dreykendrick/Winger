# Winger Backend V2 – Selcom Payment Gateway Integration & Checkout Specification

This document defines the architecture, payload contracts, HMAC-SHA256 signature verification algorithms, and security guidelines for the **Isolated Checkout System** interfacing with the Selcom Payment Gateway.

---

## 1. System Architecture & Isolation Boundary

```mermaid
graph LR
    subgraph Client Layer
        App[Flutter Mobile / Web App]
    end

    subgraph Isolated Checkout Service
        EF_CREATE[Edge Function: checkout-create]
        EF_WEBHOOK[Edge Function: checkout-webhook]
        TBL_SESSIONS[(checkout.sessions)]
        TBL_LOGS[(checkout.payment_logs)]
    end

    subgraph External Gateway
        SELCOM[Selcom Payment API]
    end

    subgraph Internal Core Platform
        OUTBOX[(audit_system.outbox)]
        OG[Order Guardian Engine]
    end

    App -->|1. Create Session| EF_CREATE
    EF_CREATE -->|2. Insert Pending Session| TBL_SESSIONS
    EF_CREATE -->> App: 3. Return Payment Gateway Redirect URL
    App ->> SELCOM: 4. Complete Mobile / Card Payment
    SELCOM ->> EF_WEBHOOK: 5. Inbound Webhook Callback + HMAC Header
    EF_WEBHOOK ->> EF_WEBHOOK: 6. Verify HMAC-SHA256 & Timestamp (<300s)
    EF_WEBHOOK ->> TBL_SESSIONS: 7. Update Session Status (COMPLETED)
    EF_WEBHOOK ->> TBL_LOGS: 8. Log Idempotent Payment Attempt
    EF_WEBHOOK ->> OUTBOX: 9. Publish checkout.payment.verified Event
    OUTBOX -.->|CDC / Cron| OG
```

---

## 2. Webhook Security Specification

### HMAC-SHA256 Signature Verification
Every inbound callback request MUST carry an `x-winger-signature` or `x-selcom-signature` header containing an HMAC-SHA256 signature computed over the raw HTTP request body string:

$$\text{Signature} = \text{HMAC-SHA256}(\text{RawBody}, \text{SELCOM\_WEBHOOK\_SECRET})$$

The `checkout-webhook` Edge Function evaluates signatures using constant-time string comparison algorithms to prevent timing side-channel attacks.

### Anti-Replay Timestamp Check
Webhook requests containing timestamp headers MUST be evaluated against current server UTC time:

$$\Delta t = |\text{Timestamp}_{\text{current}} - \text{Timestamp}_{\text{webhook}}| \le 300\text{ seconds}$$

Requests exceeding the 300-second window are rejected with `HTTP 400 TIMESTAMP_EXPIRED`.

---

## 3. Data Contracts

### 3.1 Checkout Session Request Payload (`POST /functions/v1/checkout-create`)
```json
{
  "workspace_id": "018f2d5e-1111-7000-8000-123456789abc",
  "cart_id": "018f2d5e-2222-7000-8000-123456789abc",
  "amount": 75000,
  "currency": "TZS"
}
```

### 3.2 Success Response Envelope (`HTTP 201`)
```json
{
  "success": true,
  "code": "CHECKOUT_CREATED",
  "message": "Checkout session created successfully",
  "data": {
    "checkout_session_id": "018f2d5e-3333-7000-8000-123456789abc",
    "order_reference": "WNG_1785961873_A1B2C3D4",
    "amount": 75000,
    "currency": "TZS",
    "expires_at": "2026-08-06T03:17:00Z",
    "payment_gateway_url": "https://checkout.selcom.co/pay?session=WNG_1785961873_A1B2C3D4"
  },
  "error": null,
  "timestamp": "2026-08-06T02:47:00Z"
}
```

---

## 4. Verification & Testing

- Run `pgTAP` automated database test suite:
  ```bash
  supabase test db
  ```
- Test `07_checkout_system_test.sql` to verify database table constraints and RPC session completion.

# Winger Checkout Integration Specification

**Document Title**: Sprint E Checkout Handoff & Session Lifecycle Specification  
**Version**: 1.0.0  
**Target Backend**: Winger Backend V2 & Order Guardian  
**Author**: Principal Flutter Architect  

---

## 1. Checkout System Boundaries & Architecture

Payment processing, gateway orchestration (Selcom, Meetpay), payment webhooks, and authoritative order creation belong exclusively to **Winger Checkout System** and **Winger Backend V2**.

```
Flutter Main App              Backend V2 / Checkout System           Order Guardian
      │                                     │                               │
      ├─── Create Checkout Session ────────►│                               │
      │    (cart, affiliateCode)            ├─── Reserve Inventory          │
      │◄── Return Session ID ──────────────┤                               │
      │    (chk_12345)                      │                               │
      │                                     ├─── Execute Payment            │
      ├─── Handoff Customer ───────────────►│    (Selcom, Gateway)          │
      │    (Checkout Handoff UX)            │                               │
      │                                     ├─── Create Order ─────────────►│ (Escrow Verification)
      │◄── Return Status ───────────────────┤
      │    (Success / Failed / Cancelled)
```

### Security & Privacy Rules

1. **Zero Payment Credentials in Flutter**: Flutter never receives, stores, or handles credit cards, mobile money PINs, payment gateway secrets, or webhook keys.
2. **Session Identification**: Checkout sessions are identified solely by backend-generated UUIDs/IDs (`chk_...`).
3. **No Frontend Price Authority**: All totals in checkout sessions are computed by the backend.

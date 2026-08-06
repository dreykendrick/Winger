# Winger Backend V2 – Checkout System Architecture Specification

This document defines the architecture, system boundaries, and event pipeline for the **Checkout System** implemented in **Sprint 7**.

---

## 1. Architectural Law: CHECKOUT IS AN ORCHESTRATOR

```mermaid
graph TD
    CLIENT[Customer App / Web] -->|1. Start Session| CHK[Checkout System]
    CHK -->|2. Lock Stock| RES[Inventory Reservation Engine]
    CHK -->|3. Call Gateway Adapter| ADAPT[Pluggable Gateway Adapter]
    ADAPT -->|4. Create Intent| GATEWAY[Selcom / Meetpay / Gateway]
    GATEWAY ->> CHK_WH[Edge Function: checkout-webhook-processor]
    CHK_WH -->|5. Verify Signature & Anti-Replay| CHK_WH
    CHK_WH -->|6. Publish PaymentSucceeded Event| EVT_BUS[Platform Event Bus]
    EVT_BUS -.->|7. Create Order| ORDERS[Orders Domain]
    EVT_BUS -.->|8. Lock Escrow & Ledger| FIN[Financial Core Engine]
    EVT_BUS -.->|9. Process Attribution| GROWTH[Growth Engine]
```

### Core Principles
1. **Purchase Orchestration**: Manages sessions, validation pipelines, pricing/shipping snapshots, inventory locks, and payment intent generation.
2. **Zero Financial / Fulfillment Domain Ownership**: Checkout NEVER creates orders, updates wallet balances, computes commissions, or releases escrow directly.
3. **Event-Driven Dispatch**: Payment verification publishes `checkout.payment.succeeded` to the Platform Event Bus (`audit_system.outbox`).

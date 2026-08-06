# Winger Backend V2 – Order Guardian Architecture Specification

This document defines Winger's Trust & Protection Platform implemented in **Sprint 8**.

---

## 1. Architectural Law: TRUST IS SEPARATE FROM MONEY

```mermaid
graph TD
    ORDER[Order Paid / Payment Captured] -->|1. Create Case| GUARDIAN[Order Guardian Engine]
    GUARDIAN -->|2. Create Root Case| CASES[order_guardian.protection_cases]
    GUARDIAN -->|3. Verify Delivery| VERIF[Delivery Verification Engine]
    GUARDIAN -->|4. Track 48h Window| WINDOW[Protection Window Engine]
    GUARDIAN -->|5. Evaluate Release Conditions| EVAL{Conditions Met?}
    EVAL -- Yes --> EVENT[Publish EscrowReleaseRequested Event]
    EVENT --> BUS[Platform Event Bus]
    BUS -.->|6. Execute Accounting| FIN[Financial Core Engine]
```

### Core Principles
1. **Trust Engine Responsibility**: Coordinates delivery verifications, 48h protection windows, dispute cases, evidence file stores, and SLA tracking.
2. **Zero Money Ownership**: Order Guardian NEVER mutates wallet balances, ledger entries, or escrow holdings directly.
3. **Event-Driven Financial Execution**: When release conditions pass, Order Guardian publishes `order_guardian.escrow.release_requested` to the Platform Event Bus (`audit_system.outbox`).

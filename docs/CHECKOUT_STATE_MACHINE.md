# Winger Backend V2 – Checkout State Machine Specification

Defines the formal state transitions for checkout purchasing sessions.

---

## 1. Checkout State Machine Diagram

```mermaid
stateDiagram-v2
    [*] --> DRAFT: Session Initiated
    DRAFT --> VALIDATING: Validation Pipeline
    VALIDATING --> READY_FOR_PAYMENT: Items & Stock Validated
    VALIDATING --> PAYMENT_FAILED: Validation Failure
    READY_FOR_PAYMENT --> PAYMENT_PENDING: Intent Generated
    PAYMENT_PENDING --> PAYMENT_PROCESSING: Payment In Progress
    PAYMENT_PROCESSING --> PAYMENT_SUCCESSFUL: Webhook Succeeded
    PAYMENT_PROCESSING --> PAYMENT_FAILED: Webhook Failed
    PAYMENT_SUCCESSFUL --> COMPLETED: Event Published to Bus
    READY_FOR_PAYMENT --> EXPIRED: 30-min Expiry Sweeper
```

---

## 2. Permitted Transitions
`DRAFT` $\rightarrow$ `VALIDATING` $\rightarrow$ `READY_FOR_PAYMENT` $\rightarrow$ `PAYMENT_PENDING` $\rightarrow$ `PAYMENT_PROCESSING` $\rightarrow$ `PAYMENT_SUCCESSFUL` $\rightarrow$ `COMPLETED`.

# Winger Backend V2 – Order Guardian State Machine Specification

This document defines the formal order lifecycle state machine, valid transition matrices, and trigger requirements enforced by **Order Guardian**.

---

## 1. Order State Machine Transition Diagram

```mermaid
stateDiagram-v2
    [*] --> PENDING_PAYMENT: Order Placed
    PENDING_PAYMENT --> PAID_ESCROW: Payment Verified (Selcom Webhook)
    PENDING_PAYMENT --> CANCELLED: Payment Timeout / Abandoned
    PAID_ESCROW --> SHIPPED: Vendor Ships Order
    PAID_ESCROW --> DISPUTED: Customer Raises Issue
    PAID_ESCROW --> CANCELLED: Vendor Cannot Fulfill
    SHIPPED --> DELIVERED: Logistics Confirmation
    SHIPPED --> DISPUTED: Item Lost / Damaged
    DELIVERED --> RELEASED: Customer Confirms / Auto-Release Timer Expiration
    DELIVERED --> DISPUTED: Buyer Disagrees
    DISPUTED --> RELEASED: Admin Resolves in Vendor Favor
    DISPUTED --> REFUNDED: Admin Resolves in Buyer Favor
```

---

## 2. Valid Transition Matrix

| Current State | Permitted Next States | Authorized Actors |
| :--- | :--- | :--- |
| `PENDING_PAYMENT` | `PAID_ESCROW`, `CANCELLED` | Checkout System, System Timer |
| `PAID_ESCROW` | `SHIPPED`, `DISPUTED`, `CANCELLED` | Vendor, Buyer, Admin |
| `SHIPPED` | `DELIVERED`, `DISPUTED` | Logistics Partner, Buyer, Support |
| `DELIVERED` | `RELEASED`, `DISPUTED` | Buyer, Auto-Release Sweeper (`pg_cron`) |
| `DISPUTED` | `RELEASED`, `REFUNDED` | Support Staff, Admin |

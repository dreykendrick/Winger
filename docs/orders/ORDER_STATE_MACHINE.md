# Winger Backend V2 – Orders State Machine Specification

This document defines the formal order status lifecycle and permitted transition rules.

---

## 1. State Machine Transition Diagram

```mermaid
stateDiagram-v2
    [*] --> DRAFT: Draft Order Created
    DRAFT --> PENDING_PAYMENT: Order Submitted
    PENDING_PAYMENT --> PAID: Payment Received (Event Bus)
    PENDING_PAYMENT --> CANCELLED: Payment Abandoned
    PAID --> CONFIRMED: Vendor Accepts Order
    CONFIRMED --> PREPARING: Packing Started
    PREPARING --> READY_FOR_PICKUP: Order Packed
    READY_FOR_PICKUP --> IN_TRANSIT: Courier Dispatched
    IN_TRANSIT --> DELIVERED: Recipient Sign-off
    DELIVERED --> COMPLETED: Escrow Released
    DELIVERED --> DISPUTED: Customer Dispute
    DELIVERED --> RETURNED: Product Return Initiated
    DISPUTED --> REFUNDED: Admin Dispute Refund
```

---

## 2. Valid Transition Matrix

| Current Status | Permitted Next Statuses | Transition Rule RPC |
| :--- | :--- | :--- |
| `DRAFT` | `PENDING_PAYMENT`, `CANCELLED` | `orders.fn_transition_order_status()` |
| `PENDING_PAYMENT` | `PAID`, `CANCELLED` | `orders.fn_transition_order_status()` |
| `PAID` | `CONFIRMED`, `CANCELLED` | `orders.fn_transition_order_status()` |
| `CONFIRMED` | `PREPARING`, `CANCELLED` | `orders.fn_transition_order_status()` |
| `PREPARING` | `READY_FOR_PICKUP`, `CANCELLED` | `orders.fn_transition_order_status()` |
| `READY_FOR_PICKUP` | `IN_TRANSIT`, `CANCELLED` | `orders.fn_transition_order_status()` |
| `IN_TRANSIT` | `DELIVERED`, `DISPUTED` | `orders.fn_transition_order_status()` |
| `DELIVERED` | `COMPLETED`, `RETURNED`, `DISPUTED` | `orders.fn_transition_order_status()` |
| `DISPUTED` | `COMPLETED`, `REFUNDED` | `orders.fn_transition_order_status()` |

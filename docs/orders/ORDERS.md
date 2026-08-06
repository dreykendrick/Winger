# Winger Backend V2 – Orders Domain Architecture Specification

This document defines the architecture, domain decoupling boundaries, and lifecycle specifications for the **Orders Domain** implemented in **Sprint 5**.

---

## 1. Domain Decoupling Architectural Law

```mermaid
graph TD
    CUSTOMER[Customer Purchase] -->|1. Create Order| ORDERS[Orders Domain]
    ORDERS -->|2. Generate Aggregate| AGG[Order Aggregate Root]
    ORDERS -->|3. Publish OrderCreated Event| EVT_BUS[Platform Event Bus]
    EVT_BUS -.->|4. Event Dispatch| CHECKOUT[Checkout Service]
    EVT_BUS -.->|5. Event Dispatch| OG[Order Guardian Engine]
    EVT_BUS -.->|6. Event Dispatch| GROWTH[Growth Engine]
    EVT_BUS -.->|7. Event Dispatch| NOTIF[Notification Gateway]
```

### Architectural Principles
1. **Zero Integration Coupling**: The Orders Domain contains **ZERO** payment gateway APIs, wallet balance updates, commission calculations, affiliate cookie logic, or escrow release rules.
2. **Event-Driven Communication**: State changes publish domain events (`orders.order.created`, `orders.order.paid`, `orders.order.shipped`, `orders.order.delivered`) to `audit_system.outbox`.
3. **Multi-Tenant Workspace Scoping**: Orders are owned by `organizations` and scoped to `workspaces`. RLS guarantees customers can only view their own purchases and vendors can only view orders assigned to their store.

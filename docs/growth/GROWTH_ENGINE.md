# Winger Backend V2 – Growth Engine Master Architecture Specification

This document defines the architecture, domain decoupling rules, and component specifications for the **Growth Engine (Affiliate Platform)** implemented in **Sprint 4**.

---

## 1. Domain Decoupling Architectural Law

```mermaid
graph TD
    COMMERCE[Commerce / Order Domain] -->|1. Customer Pays Order| EVT_BUS[Platform Event Bus]
    EVT_BUS -->|2. OrderPaid Event| GROWTH[Growth Engine]
    GROWTH -->|3. Resolve Attribution| ATTR[Attribution Engine]
    GROWTH -->|4. Create Conversion| CONV[Conversions Store]
    GROWTH -->|5. Evaluate Rule Precedence| RULE[Commission Engine]
    GROWTH -->|6. Generate Immutable Record| COMM[Commissions Store]
    GROWTH -->|7. Publish CommissionCalculated Event| EVT_BUS
    EVT_BUS -->|8. Event Dispatch| WALLET[Wallet Ledger Domain]
    EVT_BUS -->|9. Event Dispatch| NOTIF[Notification Gateway]
```

### Architectural Principles
1. **Zero Direct Dependency**: The Commerce/Orders domain contains **ZERO** affiliate tracking parameters, commission calculation logic, or campaign rules.
2. **Event-Driven Communication**: All communication between Orders and Growth occurs asynchronously via the **Platform Event Bus** (`audit_system.outbox`).
3. **Decoupled Evelopment**: The Growth domain or Orders domain can be rewritten or scaled independently without modifying the other.

---

## 2. Growth Domain Subsystems

- **`docs/growth/CAMPAIGNS.md`**: Marketing campaign entity specs & organization ownership.
- **`docs/growth/ATTRIBUTION.md`**: Multi-model attribution engine (`LAST_CLICK`, `FIRST_CLICK`, `TIME_DECAY`).
- **`docs/growth/COMMISSIONS.md`**: Rule evaluation precedence engine (Campaign > Product > Category > Vendor > Default).
- **`docs/growth/TRACKING.md`**: High-volume click session tracking & privacy-conscious SHA-256 IP hashing.
- **`docs/growth/FRAUD.md`**: Non-blocking fraud detection signals & risk flags.
- **`docs/growth/ANALYTICS.md`**: Daily metrics aggregation engine (`growth.analytics_daily`).

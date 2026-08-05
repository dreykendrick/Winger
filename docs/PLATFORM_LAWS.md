# Winger Backend V2 – Platform Laws (The Constitution)

**Document Title**: The Constitution of Winger Backend V2  
**Document Version**: 4.0.0  
**Status**: Immutable Supreme Architectural Framework  
**Author**: Principal Software Architect & Engineering Leadership  
**Date**: August 2026  

---

## Preamble

This document defines the **10 Immutable Platform Laws** of Winger Backend V2. These are not coding guidelines—they are permanent architectural laws that override convenience, short-term velocity, and ad-hoc optimizations.

Every sprint, migration, table, Edge Function, API endpoint, background job, external integration, and future platform feature MUST strictly comply with these laws. If any implementation conflicts with a Platform Law, engineering MUST immediately stop until a fully compliant design is produced.

---

## The 10 Platform Laws

### PLATFORM LAW 1: DOMAIN INDEPENDENCE
Every business domain MUST remain completely independent. Domains MUST NOT directly depend on or mutate each other's data stores. Communication between domains MUST occur asynchronously through the **Platform Event Bus** whenever practical. Every business domain must be replaceable without rewriting other domains.

```
Marketplace Domain → [ProductPublished Event] → Platform Event Bus → Growth Engine / Notifications / Analytics
```
*(NOT: Marketplace → Growth Engine → Wallet → Checkout)*

---

### PLATFORM LAW 2: WORKSPACE FIRST
Every business action occurs inside an active **Workspace Context**. No request may access business resources without a valid Workspace Context resolved through the **Workspace Context Service**:
$$\text{Authenticated Identity} \rightarrow \text{Workspace} \rightarrow \text{Organization} \rightarrow \text{Membership} \rightarrow \text{Roles} \rightarrow \text{Permissions}$$
Business logic must NEVER attempt to resolve this hierarchy manually.

---

### PLATFORM LAW 3: ORGANIZATIONS OWN BUSINESS DATA
Business resources (Products, Orders, Wallets, Campaigns, Stores, Settings, Inventory, Reviews, Media) belong to **Organizations**, NEVER to individual users. An individual user owns Memberships; Organizations own business data.

---

### PLATFORM LAW 4: IDENTITY IS PERMANENT
Every human person has one single **Identity** that never changes. An Identity is separate from business ownership and may simultaneously hold multiple Account Types, Workspaces, Organizations, and Roles across the platform. Authentication MUST NEVER depend on business logic.

---

### PLATFORM LAW 5: AUTHORIZATION IS DATA-DRIVEN
Permissions MUST NEVER be hardcoded into application logic. Authorization MUST always be evaluated dynamically using the Workspace Context hierarchy:
```
Workspace → Membership → Roles → Permissions
```
- **Forbidden**: `if (user.isAdmin)`
- **Mandatory**: `authorize("products.create")`

---

### PLATFORM LAW 6: EVENT-DRIVEN PLATFORM
Business events are the core integration mechanism of Winger V2. Domains react to published events rather than directly calling each other whenever practical. All events MUST be **Immutable**, **Versioned**, **Idempotent**, and **Auditable**.

---

### PLATFORM LAW 7: IMMUTABLE FINANCIAL RECORDS
Financial data is strictly **APPEND-ONLY**. Payments, Wallet Transactions, Commissions, Payouts, Refunds, and Escrow Records must NEVER be overwritten or deleted. Corrections MUST be executed using explicit compensating double-entry transactions. Every cent MUST be fully auditable.

---

### PLATFORM LAW 8: SECURE BY DEFAULT
Security is mandatory across all layers. 100% of database tables MUST enforce Row Level Security (RLS), Least Privilege, Input Validation, and Audit Logging. Every API MUST validate input, verify authentication, validate authorization, log sensitive actions, and protect secrets.

---

### PLATFORM LAW 9: PLATFORM KERNEL FIRST
Shared infrastructure concerns belong exclusively inside the **Platform Kernel**. Business domains MUST NOT duplicate Authentication, Authorization, Workspace Context, Audit Logging, Notifications, Configuration, Feature Flags, Structured Logging, Observability, or Event Publishing mechanics.

---

### PLATFORM LAW 10: DESIGN FOR EXTENSIBILITY
The platform MUST always be designed for future extension rather than today's requirements only. The architecture MUST support future scaling including Multi-Vendor, Multi-Store, Multi-Warehouse, Multi-Payment Provider, Multi-Country, Multi-Currency, Multi-Language, Enterprise Organizations, Creator Stores, and AI Recommendations without rewriting existing core modules.

---

## Mandatory Request Observability Standard

Every HTTP request and background task execution MUST be observable before it is optimized. Every request MUST include:
- **Correlation ID** (`x-correlation-id` header propagated across all services).
- **Structured JSON Logging** (`timestamp`, `level`, `correlation_id`, `workspace_id`, `event`).
- **Performance Metrics** (Execution duration timing, P95/P99 latency tracking).
- **Audit Trail** (JSON diff recording in `audit_system.audit_logs`).
- **Error Reporting** (Centralized exception capture).

---

## Architectural Review Checklist

Every sprint implementation MUST answer **YES** to all 10 questions before being approved for production deployment:

- [x] **1. Does it preserve Domain Independence?**
- [x] **2. Does it use the Workspace Context Service?**
- [x] **3. Are resources owned by Organizations?**
- [x] **4. Is Identity independent of business logic?**
- [x] **5. Is authorization data-driven?**
- [x] **6. Does it publish/consume platform events correctly?**
- [x] **7. Are financial records immutable?**
- [x] **8. Is security enforced by default (100% RLS)?**
- [x] **9. Does it use Platform Kernel services?**
- [x] **10. Is the design extensible for future growth?**

If any answer is **NO**, the implementation is incomplete and MUST NOT be merged.

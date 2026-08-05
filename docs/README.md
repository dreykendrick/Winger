# Winger Documentation Directory (`/docs`)

This directory contains the complete technical specifications, engineering principles, domain documentation, and Architecture Decision Records (ADRs) for **Winger Backend V2**.

## Supreme Constitutional Framework

- **[Platform Laws — The Constitution of Winger Backend V2](file:///c:/Users/kibaj/Winger/docs/PLATFORM_LAWS.md)**: The supreme, un-overridable 10 Platform Laws governing domain independence, workspace context, organization data ownership, permanent identity, data-driven authorization, event-driven integration, immutable financial records, secure by default, kernel-first design, and future extensibility.

## Master Architecture & Engineering Guides

- **[Platform Kernel & Core Platform Services Specification](file:///c:/Users/kibaj/Winger/docs/PLATFORM_KERNEL_ARCHITECTURE.md)**: Single source of truth blueprint defining our linear architecture pipeline (Identity → Auth → Workspace Context → Platform Kernel → Business Domains), 13 Kernel Services, Workspace Context Lifecycle, and Event Bus.
- **[Winger Engineering Principles Handbook](file:///c:/Users/kibaj/Winger/docs/ENGINEERING_PRINCIPLES.md)**: Authoritative engineering handbook outlining core values, double-entry ledger rules, security guidelines, and 10 Non-Negotiable Rules.
- **[Software Architecture Design (SAD)](file:///c:/Users/kibaj/Winger/docs/ARCHITECTURE.md)**: Master technical specification covering system boundaries, domain design, database strategies, security model, and implementation roadmap.
- **[Environment Configuration Guide](file:///c:/Users/kibaj/Winger/docs/ENVIRONMENT_CONFIG.md)**: Matrix of environment variables, secrets management, and security checklist.

## Domain Specifications Map

- **`/docs/growth/`**: Growth Engine master architecture, campaigns, attribution models, commissions rule hierarchy, click tracking, anti-fraud signals, and daily analytics.
- **`/docs/checkout/`**: Selcom integration specifications, HMAC-SHA256 signature verifier, and anti-replay timestamp checks.
- **`/docs/database/`**: Schemas, entity-relationship diagrams, and migration rollback guides.
- **`/docs/order-guardian/`**: Order state machine and escrow release rules.
- **`/docs/wallet/`**: Double-entry financial accounting ledger specification.
- **`/docs/security/`**: Role Level Security (RLS) policies and permission matrices.
- **`/docs/adr/`**: Architecture Decision Records capturing technical trade-offs and decisions.

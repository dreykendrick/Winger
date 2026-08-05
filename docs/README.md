# Winger Documentation Directory (`/docs`)

This directory contains the complete technical specifications, engineering principles, domain documentation, and Architecture Decision Records (ADRs) for **Winger Backend V2**.

## Single Source of Truth Master Blueprint

- **[Platform Kernel & Core Platform Services Specification](file:///c:/Users/kibaj/Winger/docs/PLATFORM_KERNEL_ARCHITECTURE.md)**: The authoritative single source of truth blueprint defining our linear architecture pipeline (Identity → Auth → Workspace Context → Platform Kernel → Business Domains), 13 Kernel Services, Workspace Context Lifecycle, Event-Driven Architecture, and Security Model.

## Engineering Principles & Technical Specs

- **[Winger Engineering Principles Handbook](file:///c:/Users/kibaj/Winger/docs/ENGINEERING_PRINCIPLES.md)**: The authoritative engineering constitution defining our core values, database rules, financial double-entry rules, security policies, and 10 Non-Negotiable Rules.
- **[Software Architecture Design (SAD)](file:///c:/Users/kibaj/Winger/docs/ARCHITECTURE.md)**: Technical specification covering system boundaries, domain design, database strategies, security model, and implementation roadmap.
- **[Environment Configuration Guide](file:///c:/Users/kibaj/Winger/docs/ENVIRONMENT_CONFIG.md)**: Matrix of required environment variables, secrets management, and security checklist.
- **[Sprint 1 Foundation Verification Guide](file:///c:/Users/kibaj/Winger/docs/FOUNDATION_VERIFICATION.md)**: Automated test commands, manual SQL verification queries, and acceptance checklist.

## Domain Specifications Map

- **`/docs/database/`**: Schemas, entity-relationship diagrams, and migration rollback guides.
- **`/docs/order-guardian/`**: Order state machine and escrow release rules.
- **`/docs/checkout/`**: Selcom integration specifications and webhook signature verification algorithms.
- **`/docs/wallet/`**: Double-entry financial accounting ledger specification.
- **`/docs/security/`**: Role Level Security (RLS) policies and permission matrices.
- **`/docs/adr/`**: Architecture Decision Records capturing technical trade-offs and decisions.

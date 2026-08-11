# Winger Repository & Product Specification Analysis

**Document Title**: Winger Repository Reverse Engineering & Architecture Analysis  
**Document Version**: 1.0.0  
**Target Backend**: Winger Backend V2 (Supabase)  
**Author**: Principal Flutter Architect  

---

## 1. Executive Overview

This document establishes the product specification and architectural boundary analysis derived from the existing Winger repository. The new Flutter application is a rebuild targeting **Winger Backend V2**, treating prior code as a product specification rather than a direct code port.

---

## 2. Key Domain Boundaries & Responsibilities

| Responsibility Area | Backend V2 (Supabase & Edge Functions) | Flutter Application (Main App) |
| :--- | :--- | :--- |
| **Authentication & Identity** | Password hashing, JWT issuance, custom role claim injection (`CUSTOMER`, `VENDOR`, `AFFILIATE`, `ADMIN`), MFA verification. | Credential input UI, session token persistence (`FlutterSecureStorage`), MFA challenge dialogs. |
| **Workspace Context** | Multi-tenant workspace resolution (`fn_resolve_workspace_context`), organization ownership, RLS enforcement. | Sending `X-Workspace-ID` in HTTP headers, workspace switching UI modal. |
| **Marketplace Catalog** | Stock quantity integrity, SKU price rules, full-text search indexing (`ops-search-indexer`), RLS filtering. | Catalog feed rendering, SKU selection, search filter UX, local Drift SQLite caching. |
| **Cart & Checkout** | Cart price snapshotting, inventory reservation locks (`checkout-inventory-reservations`), Selcom payment gateway URL generation, HMAC signature verification. | Cart item list UX, address selection UI, Selcom webview/USSD prompt presentation, payment status polling. |
| **Order Guardian (Trust)** | Order lifecycle state transitions (`PENDING_PAYMENT` $\rightarrow$ `PAID_ESCROW` $\rightarrow$ `SHIPPED` $\rightarrow$ `DELIVERED` $\rightarrow$ `RELEASED` / `DISPUTED`), 7-day auto-release timers, OTP/QR validation, escrow lockup. | Step-by-step realtime CDC order tracking UI, OTP/QR entry keypad, dispute photo upload picker. |
| **Growth & Affiliate** | 30-day cookie attribution token assignment (`affiliate-track`), 5-tier commission hierarchy rule evaluation, anti-fraud velocity tracking. | Referral link generator UI, 1-tap clipboard copying, native share sheet, earnings metrics UI. |
| **Financial Core & Wallet** | Double-entry ledger journal entries (`wallet_ledger.fn_execute_transaction_orchestrator`), $\sum \text{Debits} = \sum \text{Credits}$ invariant, wallet projections, payout requests. | Read-only wallet balance cards, ledger transaction history list, withdrawal request form. |

---

## 3. Screen & Navigation Blueprint

The product specification dictates 38 distinct user interface screens spanning 4 user personas:

1. **Customer Persona**: Home Catalog Feed, Product Search & Facet Filter, Product Details, Public Store Profile, Shopping Cart, Checkout Address & Gateway Selector, Selcom Payment Webview, Order Confirmation, Order History, Realtime Order Timeline, OTP/QR Delivery Verification, Raise Dispute, Dispute Center & Evidence Chat.
2. **Vendor Persona**: Vendor Overview Dashboard, Product & Inventory Manager, Add/Edit Product & SKUs, Vendor Fulfillment Hub, Vendor Order Details, Vendor Wallet & Escrows, Payout Request, Store Profile Settings.
3. **Affiliate Persona**: Affiliate Hub Dashboard, Referral Link & QR Generator, Campaigns Directory, Conversions Log, Affiliate Wallet.
4. **Admin / Ops Persona**: Ops Master Dashboard, Dispute Resolution Center, Ledger Audit & Reconciliation, Payout Batch Approval, Feature Flags & System Config.
5. **Shared Auth & Settings**: Splash, Onboarding Carousel, Login, Role Registration, MFA Verification, Workspace Switcher, App Settings.

---

## 4. Architectural Rules for Flutter Rebuild

1. **No Lovable-Specific Workarounds**: Legacy frontend workarounds created due to prototyping tool limitations are completely discarded.
2. **No Frontend Business Rules**: Commission formulas, fee splits, double-entry math, or state machine rules MUST NOT be duplicated in Flutter.
3. **Centralized Infrastructure**: All HTTP/REST API calls pass through `DioClient` with automated correlation IDs (`x-correlation-id`) and workspace headers (`x-workspace-id`).
4. **Environment Isolation**: Production, Staging, and Development environments run isolated configurations loaded from encrypted environment variables.

# Winger Vendor Merchant Experience Architecture Specification

**Document Title**: Sprint L Vendor Merchant Experience Architecture Specification  
**Version**: 1.0.0  
**Target Backend**: Winger IAM, Vendor, Product, Order, and Wallet Services  
**Author**: Principal Flutter Architect  

---

## 1. Overview & Separation of Concerns

The Winger Vendor Merchant architecture equips authorized platform vendors (`AccountType.vendor`) to manage their stores, products, order fulfillment, and wallet payouts seamlessly within the Flutter application.

```
                         VENDOR ARCHITECTURE
Authenticated Vendor ──► Workspace Context ──► Vendor Dashboard ──► Store / Product Management ──► Order Fulfillment
(AccountType.vendor)     (WorkspaceContext)   (/vendor/dashboard)   (/vendor/products)          (/vendor/orders)
```

### Core Architecture Rules

1. **Backend IAM Source of Truth**: Flutter does **NOT** grant vendor status or approve merchant verification. Account type and workspace authorization are strictly enforced by Backend V2.
2. **Financial Source of Truth**: Wallet balances, sales statistics, payout eligibility, and transaction histories are retrieved from double-entry ledger projections (Transaction Orchestrator / Wallet Service).
3. **Fulfillment State Machine**: Order status updates (`Processing`, `Ready for Shipping`, `Shipped`, `Delivered`) submit valid transition events to Backend V2 APIs.
4. **Order Guardian Representation**: Escrow protection states are clearly displayed on vendor orders without granting vendors direct escrow release authority.

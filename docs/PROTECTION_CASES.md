# Winger Backend V2 – Protection Cases Specification

Protection Cases (`order_guardian.protection_cases`) serve as the Root Aggregate for trust tracking per paid order.

---

## 1. Protection Case Structure
- **Entity**: `order_guardian.protection_cases`
- **Fields**: `order_reference`, `customer_profile_id`, `vendor_id`, `organization_id`, `workspace_id`, `status`, `escrow_status`, `delivery_status`, `protection_window_expires_at`.
- **Status Lifecycle**: `ACTIVE` $\rightarrow$ `DELIVERY_VERIFIED` $\rightarrow$ `RELEASE_REQUESTED` $\rightarrow$ `COMPLETED` / `DISPUTED`.

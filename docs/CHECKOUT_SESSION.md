# Winger Backend V2 – Checkout Session Aggregate Specification

The Checkout Session (`checkout.sessions`) encapsulates pricing, shipping, items, and inventory reservation snapshots during active purchases.

---

## 1. Checkout Session Structure
- **Entity**: `checkout.sessions`
- **Fields**: `customer_profile_id`, `workspace_id`, `organization_id`, `order_reference`, `subtotal`, `shipping_cost`, `tax_amount`, `discount_amount`, `grand_total`, `status`, `expires_at`, `correlation_id`.
- **Sub-Snapshots**: `checkout.session_items`, `checkout.pricing_snapshots`, `checkout.shipping_snapshots`, `checkout.inventory_reservations`.

# Winger Cart Architecture Specification

**Document Title**: Sprint E Guest Cart & Validation Specification  
**Version**: 1.0.0  
**Target Backend**: Winger Backend V2 (Supabase PostgREST)  
**Author**: Principal Flutter Architect  

---

## 1. Overview & Cart Lifecycle

The Winger Cart is a **guest-accessible, client-persisted, backend-validated** shopping cart.

```
Guest Product Selection ──► Local Cart Storage ──► Pre-Checkout Validation ──► Checkout Session
(Product Detail Screen)     (SharedPreferences)    (Backend V2 PostgREST)      (Checkout System Handoff)
```

### Core Architecture Rules

1. **Unauthenticated Accessibility**: Customers can add items, change quantities, remove items, and clear cart without login or registration.
2. **Local Hybrid Persistence**: Cart contents are serialized as JSON in local preferences (`winger_guest_cart`).
3. **Backend Validation Authority**: Prior to checkout handoff, the cart is validated against Winger Backend V2 (`products` table / RPC) to verify pricing, stock availability, and merchant status.

---

## 2. Component Layout (`lib/features/cart/`)

- `CartItemCard`: Material 3 card displaying product image, title, variant, merchant, quantity selector, price, and remove icon.
- `CartQuantityControl`: Accessible `-` and `+` button widget.
- `CartSummaryCard`: Card showing subtotal, referral attribution tag, pre-checkout disclaimer, and checkout CTA.
- `EmptyCartView`: State widget displayed when cart contains 0 items.

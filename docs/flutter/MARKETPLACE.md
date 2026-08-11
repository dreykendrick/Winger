# Winger Marketplace Architecture Specification

**Document Title**: Sprint D Public Marketplace & Product Catalog Specification  
**Version**: 1.0.0  
**Target Backend**: Winger Backend V2 (Supabase PostgREST)  
**Author**: Principal Flutter Architect  

---

## 1. Overview & Architectural Principles

The Winger Marketplace is a **public-first, guest-accessible e-commerce feed**.

```
Unauthenticated Visitor / Customer
       │
       ▼
Marketplace HomeScreen ──► Product Detail ──► Guest Checkout (/checkout)
(No Auth Required)         (No Auth Required) (Independent Guest Flow)
```

### Core Architecture Rules

1. **Guest Browsing & Purchasing**: Customers are guest commerce participants. Browsing products, searching categories, viewing media, reading customer reviews, and proceeding to checkout require **zero authentication**.
2. **Backend Source of Truth**: Winger Backend V2 is authoritative for pricing, compare-at pricing, inventory availability, discounts, review ratings, and merchant info. Flutter never computes prices or reserves stock locally.
3. **Affiliate Attribution Preservation**: Referral codes attached to deep links (`/affiliate/:code`) are stored in navigation context without modifying customer guest access.

---

## 2. Component System (`lib/features/marketplace/`)

- `ProductCard`: Material 3 product card with discount tags, compare-at prices, star ratings, and CTA button.
- `ProductShimmer`: Skeleton loader placeholder.
- `CategoryCarousel`: Scrollable filter chips for category switching.
- `FilterBottomSheet`: Modal sheet for sorting (newest, price low-to-high, price high-to-low, rating) and stock filters.
- `MediaGallery`: Swipeable image viewer with page indicators.
- `ReviewsList`: Customer feedback breakdown and rating stats.

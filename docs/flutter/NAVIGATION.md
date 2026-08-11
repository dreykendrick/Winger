# Winger Navigation Architecture Specification

**Document Title**: Sprint C Centralized Navigation & Routing Specification  
**Version**: 2.0.0  
**Router Framework**: GoRouter  
**Author**: Principal Flutter Architect  

---

## 1. Overview & Core Routing Principles

The Winger Main App uses a **Centralized Stateful Navigation Architecture** powered by **GoRouter**.

```
                           AppRouter (GoRouter)
                                   │
      ┌────────────────────────────┼────────────────────────────┐
      ▼                            ▼                            ▼
Public Marketplace           Guest Checkout             Protected Actors
  (/, /home, /product/:id)     (/checkout)                 (/vendor/*, /affiliate/*, /admin/*)
  [Zero Auth Required]       [Guest Independent]          [Guarded by IdentityContext]
```

### Key Principles

1. **Public Accessibility**: Browsing marketplace products, categories, search results, and opening referral links requires **zero authentication**.
2. **Guest Checkout Independence**: Guest purchasing (`/checkout`) is decoupled from Main App user authentication.
3. **Actor Isolation**: Protected routes (`/vendor/*`, `/affiliate/*`, `/admin/*`) use stateful navigation shells (`StatefulShellRoute`) and are guarded by the `IdentityContext` established in Sprint B.
4. **Typed Navigation**: Widgets utilize `AppNavigator` typed helpers rather than scattered hardcoded string paths.

---

## 2. Route Hierarchy Summary

| Route Domain | Path Pattern | Access Level | Shell / Navigation |
| :--- | :--- | :--- | :--- |
| **Marketplace** | `/home`, `/marketplace`, `/search` | Public | `MarketplaceShell` (`NavigationBar`) |
| **Product Detail** | `/product/:productId` | Public | Page View |
| **Affiliate Link** | `/affiliate/:affiliateCode` | Public | Deep Link Resolver |
| **Guest Checkout** | `/checkout` | Public Guest | Page View |
| **Auth Forms** | `/login`, `/register`, `/forgot-password` | Public Guest | Page View |
| **Vendor Space** | `/vendor/dashboard`, `/vendor/products`, `/vendor/orders` | Protected (`VENDOR`) | `VendorShell` (`NavigationRail`) |
| **Affiliate Space** | `/affiliate/dashboard`, `/affiliate/links`, `/affiliate/earnings` | Protected (`AFFILIATE`) | `AffiliateShell` (`NavigationBar`) |
| **Admin Space** | `/admin/dashboard`, `/admin/users`, `/admin/vendors` | Protected (`ADMIN`) | `AdminShell` (`NavigationRail`) |
| **Errors** | `/401`, `/403`, `/404` | Public | Error Destinations |

---

## 3. Deep Linking & Attribution Strategy

- Cold start URLs (e.g. `https://winger.co/product/prod_123` or `https://winger.co/affiliate/REF99`) resolve directly via `GoRouter` path parameter matching.
- Referral links resolve affiliate codes in the background while keeping the public user on the target marketplace store view.

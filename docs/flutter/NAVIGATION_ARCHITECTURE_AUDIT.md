# WINGER NAVIGATION & SCREEN ARCHITECTURE AUDIT

**Document Title**: Winger Main Application Navigation Architecture Audit & Destination Mapping  
**Version**: 2.0.0  
**Date**: August 09, 2026  

---

## 1. Audit Summary & Previous Incorrect Mappings

| Bottom Nav Destination | Previous Incorrect Mapping | Corrected Mapping & Screen Ownership | Status |
| :--- | :--- | :--- | :---: |
| **1. HOME** | `MarketplaceHomeScreen` | `MarketplaceHomeScreen` (Main Storefront Discovery Feed) | **CORRECT** |
| **2. PRODUCTS** | `CategoryProductsScreen(categoryId: 'all')` | `CategoryProductsScreen(categoryId: 'all')` (Marketplace Browsing) | **CORRECT** |
| **3. ORDERS** | `SearchScreen` (`/search`) | `OrdersListScreen` (`/orders` - Filter Tabs: All, Processing, Shipped, Delivered) | **FIXED** |
| **4. WALLET** | `CartScreen` (`/cart`) | `WalletDashboardScreen` (`/wallet` - Balances, Ledger Transactions, Withdrawals) | **FIXED** |
| **5. MORE** | `ProfilePlaceholderScreen` (`/profile`) | `MoreScreen` (`/more` - Utility Menu: Profile, Settings, Workspaces, Support, Logout) | **FIXED** |

---

## 2. Information Architecture & Stateful Shell Mapping

```
StatefulShellRoute.indexedStack (MarketplaceShell)
 ├── Branch 0 (HOME)     : /home     ──► MarketplaceHomeScreen
 ├── Branch 1 (PRODUCTS) : /products ──► CategoryProductsScreen (Marketplace Catalog)
 ├── Branch 2 (ORDERS)   : /orders   ──► OrdersListScreen (Order Management & Status Tabs)
 ├── Branch 3 (WALLET)   : /wallet   ──► WalletDashboardScreen (Backend Ledger Balance Projections)
 └── Branch 4 (MORE)     : /more     ──► MoreScreen (Utility Menu Container)
                                         └── Child: /more/profile ──► ProfilePlaceholderScreen
```

### Standalone Top-Level Routes (Outside Bottom Navigation)
- **Search (`/search`)**: Top-level route accessible via Search bar in Home & Products header $\rightarrow$ `SearchScreen()`.
- **Cart (`/cart`)**: Top-level route accessible via Cart icon in top AppBar header $\rightarrow$ `CartScreen()`.
- **Checkout (`/checkout`)**: Top-level handoff route from Shopping Cart $\rightarrow$ `CheckoutHandoffScreen()`.

---

## 3. Back Button Behavior & State Preservation

- Switching bottom navigation tabs preserves tab state via `StatefulShellRoute.indexedStack`.
- Pushing secondary routes (e.g. `/more/profile`, `/orders/:id`, `/product/:id`, `/search`, `/cart`) preserves the back stack: pressing Back predictably returns to the originating screen context without causing navigation loops.

---

## 4. Verification & Automated Test Results

- **`dart format .`**: **Clean format across all 262 files**.
- **`flutter analyze`**: **0 issues found** (100% clean).
- **`flutter test`**: **105 / 105 tests passed cleanly** (including `test/navigation/navigation_architecture_test.dart`).
- **Release APK**: Built successfully at `build/app/outputs/flutter-apk/app-release.apk`.

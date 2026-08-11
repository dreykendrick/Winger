# Winger Customer Orders Architecture Specification

**Document Title**: Sprint I Customer Orders Specification  
**Version**: 1.0.0  
**Target Backend**: Winger Orders Domain & Backend V2  
**Author**: Principal Flutter Architect  

---

## 1. Overview & Separation of Concerns

The Winger Orders architecture governs **Customer Guest Order Access** and **Historical Data Integrity**.

```
                   GUEST CUSTOMER ORDERS ARCHITECTURE
Guest Checkout ──► Tracking Token / Session Ref ──► Orders List Screen ──► Order Detail Screen ──► Delivery Tracking
                                                   (/orders)              (/orders/:id)         (/orders/:id/tracking)
```

### Core Architecture Rules

1. **Guest Order Access**: Customers do NOT require a Winger account or sign-in. Orders are accessed securely via tracking tokens or checkout session references.
2. **Historical Data Integrity**: Order line items, product titles, prices, vendor names, and shipping fees reflect exact historical commercial values captured at purchase time. They are **never replaced** with live Marketplace values.
3. **Status Separation**: Fulfillment Order Status (`OrderStatus`), Payment Status (`PaymentStatus`), and Order Guardian Protection Status (`GuardianStatus`) are explicitly rendered separately.

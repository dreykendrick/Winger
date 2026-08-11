# Winger Notifications & Activity Architecture Specification

**Document Title**: Sprint J Notifications & Activity Architecture Specification  
**Version**: 1.0.0  
**Target Backend**: Winger Notification Engine & Event Bus  
**Author**: Principal Flutter Architect  

---

## 1. Overview & Separation of Concerns

The Winger Notifications architecture consumes domain events dispatched by Backend V2's **Notification Engine** and **Event Bus**.

```
                         NOTIFICATIONS ARCHITECTURE
Backend Event Bus ──► Notification Engine ──► Supabase Realtime Stream ──► Notification Center ──► Safe Deep Link Navigation
(Order/Payment/Wallet) (Authoritative Records) (PostgREST / Push)          (/notifications)       (Order/Wallet/Guardian)
```

### Core Architecture Rules

1. **Backend Event Source of Truth**: Flutter does **NOT** generate business notifications or decide when business events occur. It strictly consumes authoritative backend notification records.
2. **Actor & Workspace Scoping**: Notifications are fetched strictly for the authenticated actor context.
3. **Informational Boundary**: Financial notifications (Wallet deposits, Withdrawals, Payments, Commissions) are strictly informational. Flutter always queries authoritative financial endpoints upon opening notifications.
4. **Deduplication**: Notifications are deduplicated using stable backend `notification.id` across Realtime stream, Push notifications, and REST pagination.

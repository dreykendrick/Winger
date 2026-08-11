# Winger Flutter Client Architecture Specification

**Document Version**: 1.0.0  
**Status**: Approved Architecture Specification  
**Author**: Principal Flutter Architect  

---

## 1. Overview & Clean Architecture Principles

The Winger Flutter client application is built using **Feature-First Clean Architecture**.

```
lib/
  app/         # Global Application Configuration, Theme, Router, Providers
  core/        # Shared Cross-Cutting Infrastructure Drivers (Network, Storage, Errors, Logging)
  features/    # Domain-bounded Feature Modules (Auth, Marketplace, Orders, Checkout, etc.)
  shared/      # Reusable UI Design System, Widgets, Components, Extensions
```

### Architectural Layering Rules

1. **Presentation Layer (`features/<feature>/presentation/`)**:
   - Manages UI widgets, layout, screens, and user interaction.
   - Binds UI states using Riverpod `Notifier` / `AsyncNotifier` (`AsyncValue`).
   - Does **NOT** execute raw SQL, HTTP requests, or business rule math directly.

2. **Domain Layer (`features/<feature>/domain/`)**:
   - Contains immutable presentation data entities (`freezed`).
   - Defines abstract repository interface contracts (`abstract class FeatureRepository`).

3. **Data Layer (`features/<feature>/data/`)**:
   - Implements repository interface contracts.
   - Orchestrates remote data sources (`SupabaseClient`, `DioClient`) and local storage (`DriftDatabase`, `SecureStorageService`).
   - Maps DTO JSON payloads into domain entities.

---

## 2. Source of Truth Boundary Law

The Winger Backend V2 (Supabase PostgreSQL + 50 Edge Functions) is the **single source of truth** for:
- Authentication authority and JWT claim validation
- Multi-tenant workspace RLS isolation
- Inventory reservation and stock locking
- Order Guardian state machine transition validation
- Double-entry financial accounting ledger entries
- 30-day affiliate attribution and commission rule hierarchy

The Flutter app is strictly responsible for:
- Presentation and user interaction
- Navigation & deep linking (`/ref/:code`)
- UI state management via Riverpod
- Network API calls & Supabase Realtime subscriptions
- Local UI caching (Drift SQLite) & offline outbox queueing
- Client-side input format validation (regex, non-empty)

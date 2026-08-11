# Roles & Permissions Specification

## Roles & Permissions Model

Roles (e.g. `WORKSPACE_OWNER`, `STORE_MANAGER`, `FINANCE_CLERK`) are scoped collections of fine-grained permissions.

### Client-Side Permission Lookup

The `IdentityContext` provides a helper method `can(permissionKey)` for UI presentation hints:
- `can('catalog:product:create')`
- `can('escrow:release')`
- `can('payout:request')`

> [!NOTE]
> Client-side permission checks control UI element visibility (e.g., hiding a button). They are never treated as a security boundary. The backend RLS policy always evaluates permissions authoritatively.

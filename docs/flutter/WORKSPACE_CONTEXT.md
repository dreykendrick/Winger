# Workspace Context Specification

All products, orders, catalogs, and financial balances in Winger Backend V2 belong to a specific **Workspace**.

## Workspace Context Rules

1. **Header Injection**: Every API call executed via `DioClient` automatically includes:
   ```
   X-Workspace-ID: <active_workspace_id>
   ```
2. **Database Scoping**: PostgreSQL session variables set `app.current_workspace_id`, enforcing multi-tenant RLS rows filtering.
3. **Workspace Switching**: Selecting a new active workspace re-aggregates effective roles and permissions without requiring re-login.
4. **Logout Purge**: Clearing workspace context from `SecureStorageService` upon user sign-out.

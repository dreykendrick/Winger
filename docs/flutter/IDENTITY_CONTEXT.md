# Identity Context Specification

## Overview

After authentication, the Flutter client hydrates the user's **IdentityContext** from Winger Backend V2.

```
User (Identity Principal)
  ├── UserProfile (Name, Email, Avatar)
  ├── AccountTypes (Customer, Vendor, Affiliate)
  ├── Organization Memberships (Parent Business Entities)
  └── Active Workspace Context (Isolated Multi-Tenant Store Boundary)
        ├── Assigned Roles (Workspace Owner, Store Manager, Finance Clerk)
        └── Effective Permissions (catalog:create, escrow:release, payout:request)
```

## Security Rule

Identity Context values are strictly **client-side presentation context**. The Winger Backend V2 remains the sole authorization authority enforcing access control via Row Level Security (RLS) policies.

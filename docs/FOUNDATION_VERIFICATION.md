# Winger Backend V2 – Sprint 1 Foundation Verification & Acceptance Guide

This guide details how to verify the foundational database schema, Row Level Security (RLS) policies, storage buckets, and Edge Functions implemented in **Sprint 1**.

---

## 1. Automated Verification Commands

### Database & Security Tests (pgTAP)
Run the automated SQL test suite using Supabase CLI:

```bash
# Execute all database tests against local Supabase instance
supabase test db
```

### Edge Functions Health Verification
Start local Edge Functions server and verify the health check endpoint:

```bash
# Start Edge Functions locally
supabase functions serve &

# Query health-check endpoint
curl -i http://localhost:54321/functions/v1/health-check
```

*Expected HTTP Response*:
```json
{
  "success": true,
  "code": "HEALTH_OK",
  "message": "Health check passed",
  "data": {
    "status": "UP",
    "service": "Winger Edge Gateway",
    "environment": "development"
  },
  "error": null,
  "timestamp": "2026-08-05T08:32:00.000Z"
}
```

---

## 2. SQL Verification Queries

Run these queries in Supabase Studio SQL Editor to manually inspect the foundation setup:

### Verify UUIDv7 Function
```sql
SELECT public.gen_random_uuid_v7() AS uuid_v7_sample;
```

### Verify Table RLS Status
```sql
SELECT 
    schemaname,
    tablename,
    rowsecurity AS rls_enabled
FROM pg_tables 
WHERE schemaname IN ('public', 'audit_system')
ORDER BY tablename;
```
*Acceptance Criteria*: `rls_enabled` must be `true` for 100% of tables.

### Verify Storage Buckets Setup
```sql
SELECT id, name, public, file_size_limit, allowed_mime_types 
FROM storage.buckets;
```

---

## 3. Sprint 1 Acceptance Checklist

- [x] **Project Scaffolding**: Folder layout established for `migrations/`, `functions/`, `tests/`, `docs/`, `scripts/`.
- [x] **Schema Isolation**: `order_guardian`, `wallet_ledger`, and `audit_system` schemas created.
- [x] **UUIDv7 Primary Keys**: `gen_random_uuid_v7()` function created and applied across all table schemas.
- [x] **Global Enums**: Enums defined for `enum_user_role`, `enum_account_status`, `enum_verification_status`, `enum_notification_channel`, `enum_language`, `enum_currency`.
- [x] **Foundational Tables**: `profiles`, `roles`, `permissions`, `user_roles`, `settings`, `feature_flags`, and `audit_logs` created.
- [x] **Auth Profile Sync**: `trg_on_auth_user_created` trigger automatically generates a public profile and assigns default `CUSTOMER` role upon sign-up.
- [x] **JWT Custom Claims Hook**: `fn_enrich_jwt_claims()` enriches JWT metadata with `user_role`.
- [x] **Row Level Security**: RLS enabled on 100% of tables with explicit role-based access policies.
- [x] **Storage Architecture**: Storage buckets (`avatars`, `vendor-assets`, `product-images`, `documents`, `delivery-proofs`) configured with upload limits and MIME type rules.
- [x] **Shared Edge Functions**: Health check, CORS, Response envelope builder, HMAC verifier, and Audit Logger utilities implemented.
- [x] **Automated Testing**: pgTAP database and security test suites created.

---

## 4. Transition to Sprint 2

With the foundation complete, Winger Backend V2 is ready for **Sprint 2: Marketplace Catalog, Vendor Store Onboarding & Affiliate Attribution Engine**.

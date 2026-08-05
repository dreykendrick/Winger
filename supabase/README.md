# Winger Supabase Directory (`/supabase`)

This directory contains all database migrations, Edge Functions, automated pgTAP tests, and Supabase CLI configuration for **Winger Backend V2**.

## Directory Layout

- **`config.toml`**: Supabase CLI project configuration.
- **`seed.sql`**: Local development seed data.
- **`migrations/`**: Chronological SQL migration files (`YYYYMMDDHHMMSS_description.sql`).
- **`functions/`**: Deno TypeScript Edge Functions (`checkout-create`, `checkout-webhook`, `order-guardian-release`, etc.).
- **`tests/`**: Automated database security (pgTAP) and Edge Function unit test suites.

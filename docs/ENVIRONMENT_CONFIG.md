# Winger Backend V2 – Environment Configuration Guide

This document defines all environment variables and secrets required for local development, staging, and production environments for **Winger Backend V2**.

---

## 1. Environment Variable Reference Matrix

| Variable Name | Required Scope | Example / Value Format | Sensitive? | Description & Usage |
| :--- | :--- | :--- | :--- | :--- |
| `ENVIRONMENT` | All Environments | `development` / `staging` / `production` | No | Target runtime environment tag used for logging and conditional behavior. |
| `SUPABASE_URL` | All Edge Functions | `https://xyzproject.supabase.co` | No | Main Supabase project REST API endpoint URL. |
| `SUPABASE_ANON_KEY` | Flutter Client / Gateway | `eyJhbGciOiJIUzI1NiIsIn...` | No | Public Supabase anon key safe for client-side inclusion. Guarded by RLS. |
| `SUPABASE_SERVICE_ROLE_KEY` | Edge Functions / CI/CD | `eyJhbGciOiJIUzI1NiIsIn...` | **YES** | Secret administrative key bypassing RLS. Must **NEVER** be leaked or exposed to frontend. |
| `SELCOM_API_KEY` | Checkout Edge Function | `SELCOM_API_KEY_LIVE_...` | **YES** | Selcom Payment Gateway API authentication key. |
| `SELCOM_API_SECRET` | Checkout Edge Function | `SELCOM_SECRET_LIVE_...` | **YES** | Selcom secret token used for API request authorization headers. |
| `SELCOM_WEBHOOK_SECRET` | Checkout Webhook Function | `whsec_HMAC_SECRET_...` | **YES** | Secret key used to verify incoming Selcom webhook HMAC-SHA256 signatures. |
| `FCM_SERVER_KEY` | Notification Function | `AAAAn123456789...` | **YES** | Firebase Cloud Messaging server key for dispatching push notifications. |
| `SENDGRID_API_KEY` | Notification Function | `SG.123456789...` | **YES** | Transactional email provider API key. |

---

## 2. Managing Secrets in Supabase CLI

To set secrets securely in your Supabase project without committing them to version control:

```bash
# Set secrets in remote Supabase environment
supabase secrets set SELCOM_API_KEY="your-live-key"
supabase secrets set SELCOM_WEBHOOK_SECRET="your-hmac-secret"

# List configured secrets (values remain hidden)
supabase secrets list
```

For local Edge Function testing, create a file named `supabase/functions/.env.local` (added to `.gitignore`):

```ini
ENVIRONMENT=development
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_SERVICE_ROLE_KEY=ey...
SELCOM_WEBHOOK_SECRET=local_dev_secret_key
```

---

## 3. Security Hardening Checklist

1. **Zero Hardcoded Secrets**: Ensure `git diff` shows no plain-text credentials in `.ts`, `.sql`, or `.toml` files.
2. **Key Rotation**: Rotate `SELCOM_WEBHOOK_SECRET` and `SUPABASE_SERVICE_ROLE_KEY` every 90 days.
3. **Environment Isolation**: Staging and Production MUST use separate Supabase project IDs and separate Selcom merchant accounts.

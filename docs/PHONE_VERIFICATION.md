# WINGER — Briq Phone Verification & SMS Setup

This document describes the environment secrets and backend configuration required to activate Briq SMS verification for Winger Backend V2.

## Required Supabase Secrets

To enable Briq SMS dispatch in Supabase Edge Functions, set the following secrets in your Supabase Dashboard under:
`Dashboard → Project Settings → Edge Functions → Secrets`

Or set them locally/via CLI:

```bash
supabase secrets set BRIQ_API_KEY="your_briq_api_key_here"
supabase secrets set BRIQ_APP_ID="your_optional_app_id_here"
supabase secrets set BRIQ_SENDER_ID="Winger"
```

### Environment Variable References

| Variable | Description | Example |
|---|---|---|
| `BRIQ_API_KEY` | Production API Key created in Briq Karibu Dashboard | `briq_live_abc123...` |
| `BRIQ_APP_ID` | Optional Developer App ID | `app_9876` |
| `BRIQ_SENDER_ID` | Approved SMS Sender ID registered with Briq | `Winger` |

## Authoritative OTP Flow Architecture

```
Flutter (Client)
  ↓ POST /functions/v1/send-phone-otp { phone_number }
Backend V2 Edge Function (send-phone-otp)
  ↓ POST https://karibu.briq.tz/v1/otp/request
Briq Karibu SMS Gateway
  ↓ SMS Delivered to Recipient Phone
User Enters 6-Digit OTP Code
  ↓ POST /functions/v1/verify-phone-otp { phone_number, code }
Backend V2 Edge Function (verify-phone-otp)
  ↓ POST https://karibu.briq.tz/v1/otp/verify
Briq Verification Confirmation
  ↓ Call fn_complete_phone_verification() Atomic RPC
Profiles Table Updated (phone_number, account_status = 'ACTIVE')
Verifications Table Inserted (type = 'PHONE', status = 'APPROVED')
```

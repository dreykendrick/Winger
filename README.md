# Winger — Multi-Vendor E-Commerce & Affiliate Platform

Winger is a high-performance, multi-vendor marketplace platform built with Flutter and Supabase Backend V2. It supports multi-tenant vendor stores, affiliate attribution tracking, escrow order protection, and phone OTP authentication.

---

## 🚀 Getting Started

Follow these steps to set up and run the Winger Flutter application locally.

### 1. Prerequisites
- **Flutter SDK**: `>=3.19.0`
- **Dart SDK**: `>=3.3.0`
- **Java JDK**: Version 17
- **Supabase Account & Project**: Project reference on Supabase Cloud.

---

### 2. Environment Configuration (`.env.development`)

Before running the application, you must create a `.env.development` file at the root of the repository.

1. Copy `.env.example` to `.env.development`:
   ```bash
   cp .env.example .env.development
   ```

2. Open `.env.development` and fill in your Supabase credentials:
   ```env
   # Winger Flutter App Environment Configuration - DEVELOPMENT
   ENVIRONMENT=development
   APP_NAME=Winger Dev
   APP_BUNDLE_ID=co.winger.app.dev

   # Supabase Backend V2 Configuration
   SUPABASE_URL=https://<project-ref>.supabase.co
   SUPABASE_ANON_KEY=<your_public_anon_key>

   # API & Gateway Configuration
   API_BASE_URL=https://<project-ref>.supabase.co/functions/v1
   API_TIMEOUT_SECONDS=15
   ENABLE_LOGGING=true
   ENABLE_ANALYTICS=false
   ```

> 💡 **Where to find your Supabase credentials:**
> - Go to your [Supabase Dashboard](https://supabase.com/dashboard).
> - Select your project -> **Project Settings** (gear icon) -> **API**.
> - Copy **Project URL** to `SUPABASE_URL`.
> - Copy **Project API Keys** (`anon` / `public`) to `SUPABASE_ANON_KEY`.

> ⚠️ **Note:** `SupabaseService.initialize()` will fail loudly with a `StateError` if credentials are missing or set to default placeholder strings.

---

### 3. Install Dependencies & Run

```bash
# Fetch Flutter package dependencies
flutter pub get

# Run static analysis
flutter analyze --no-fatal-infos

# Run unit & widget test suite
flutter test

# Start the application in development mode
flutter run
```

---

## 🔐 Phone Verification & Briq Edge Function Configuration

Winger requires **Phone OTP Verification** for account activation (email confirmation is not required).

### Setting Edge Function Secrets
To configure the Briq SMS Gateway in Supabase Cloud, set the following secrets via the Supabase CLI:

```bash
npx supabase secrets set \
  BRIQ_API_KEY="your_briq_api_key" \
  BRIQ_SENDER_ID="BRIQ" \
  --project-ref <project-ref>
```

### Developer Testing Bypass
For local testing without relying on live SMS delivery, the `verify-phone-otp` Edge Function accepts developer bypass codes:
- **Test Code**: `123456` or `000000`
- Entering `123456` on the verification screen completes the `fn_complete_phone_verification` database transaction instantly and activates the profile.

---

## 🏛️ Project Architecture

- `lib/app/`: Application bootstrap, routing (`app_router.dart`), and environment config (`env_config.dart`).
- `lib/core/`: Centralized logger (`AppLogger`), exceptions, failure hierarchy, network providers (`supabase_client_provider.dart`).
- `lib/features/`: Feature modules (Auth, Marketplace, Order Guardian, Wallet, Vendor, Affiliate).
- `supabase/`: Database migrations (SQL) and Deno Edge Functions.

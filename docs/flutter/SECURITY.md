# Security Architecture & Policies

## Policies

1. **No Secrets in Code**: Zero private backend keys embedded in Flutter source.
2. **Encrypted Key Storage**: `FlutterSecureStorage` stores authentication JWTs using Android EncryptedSharedPreferences and iOS Keychain.
3. **Safe Logging**: `AppLogger._sanitize(...)` strips passwords, JWT tokens, and credentials from log outputs.
4. **Workspace Scoping**: Every API call includes `X-Workspace-ID` header enforcing server-side RLS multi-tenant scoping.

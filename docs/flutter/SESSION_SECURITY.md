# Session Security Specification

## Security Measures

1. **Encrypted Session Tokens**: Auth tokens stored exclusively via `SecureStorageService` using iOS Keychain and Android EncryptedSharedPreferences.
2. **Purge on Logout**: Signing out purges session tokens, user profiles, workspace IDs, and permission caches.
3. **No Secret Logging**: `AppLogger._sanitize()` strips JWT tokens, passwords, and secrets from log strings.
4. **Token Refresh**: Supabase Auth SDK auto-refreshes expired access tokens in the background via PKCE.

# Networking Architecture & API Integration

All HTTP requests pass through `DioClient` (`lib/core/network/dio_client.dart`) and `SupabaseService` (`lib/core/network/supabase_client_provider.dart`).

## Interceptor Pipeline

1. **Correlation ID Injection**: Every request generates `X-Correlation-ID: corr_<uuid>` for distributed tracing.
2. **Auth Header Injection**: Automatically attaches `Authorization: Bearer <jwt>` from `SecureStorageService`.
3. **Workspace Context Injection**: Automatically attaches `X-Workspace-ID: <workspace_id>` (enforces Platform Law 2).
4. **Error Normalization**: Maps raw HTTP errors into `AppException` and `Failure` sealed class instances (`NetworkError`, `AuthError`, `ForbiddenError`, `ServerError`, `TimeoutError`).

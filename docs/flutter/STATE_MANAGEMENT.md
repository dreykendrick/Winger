# State Management Architecture (Riverpod)

Winger uses **Riverpod 2.0** for state management and dependency injection.

## Conventions

- **Storage Providers**: Singletons for `SecureStorageService`, `PreferencesService`.
- **Network Providers**: Singletons for `DioClient`, `ConnectivityService`.
- **Notifier Conventions**: Use `StateNotifier` or `Notifier` for reactive UI state.
- **Async State Conventions**: Wrap async UI data in `AsyncValue<T>` for automatic loading/error handling.
- **Dependency Overrides**: Root `ProviderScope` in `main.dart` overrides initialized services.

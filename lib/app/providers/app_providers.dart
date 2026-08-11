import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/preferences_service.dart';
import '../../core/storage/secure_storage_service.dart';

/// Centralized Dependency Injection & Global State Infrastructure Providers.

// Storage Providers
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final preferencesProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError(
      'preferencesProvider must be initialized in ProviderScope override');
});

// Network & Connectivity Providers
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});

final dioClientProvider = Provider<DioClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return DioClient(secureStorage: secureStorage);
});

// Global Application State Notifiers
class AppThemeModeNotifier extends StateNotifier<String> {
  final PreferencesService _prefs;

  AppThemeModeNotifier(this._prefs) : super(_prefs.getThemeMode());

  void setThemeMode(String mode) {
    state = mode;
    _prefs.setThemeMode(mode);
  }
}

final appThemeModeProvider =
    StateNotifierProvider<AppThemeModeNotifier, String>((ref) {
  final prefs = ref.watch(preferencesProvider);
  return AppThemeModeNotifier(prefs);
});

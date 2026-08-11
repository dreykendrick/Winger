import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers/app_providers.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../controllers/auth_controller.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(
    supabaseClient: SupabaseService.client,
    secureStorage: secureStorage,
  );
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authControllerProvider);
});

final currentUserProvider = Provider<UserProfile?>((ref) {
  final state = ref.watch(authStateProvider);
  if (state is Authenticated) {
    return state.user;
  }
  return null;
});

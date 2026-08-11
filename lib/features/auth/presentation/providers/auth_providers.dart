import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/entities/identity_context.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../controllers/auth_controller.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(SupabaseService.client);
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
  final repository = ref.watch(authRepositoryProvider);
  ref.watch(authStateProvider);
  return repository.currentUser;
});

final identityContextProvider = Provider<IdentityContext>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  ref.watch(authStateProvider);
  return repository.identityContext;
});

class AuthObserverNotifier extends ChangeNotifier {
  AuthObserverNotifier(Ref ref) {
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final authObserverProvider =
    ChangeNotifierProvider<AuthObserverNotifier>((ref) {
  return AuthObserverNotifier(ref);
});

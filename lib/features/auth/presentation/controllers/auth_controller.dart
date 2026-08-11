import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/logging/app_logger.dart';

import '../../domain/entities/auth_state.dart';
import '../../domain/entities/identity_context.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const Unauthenticated()) {
    restoreSession();
  }

  Future<void> restoreSession() async {
    state = const Authenticating();
    final userResult = await _authRepository.getCurrentUser();

    userResult.switchValue(
      onSuccess: (user) async {
        if (user == null) {
          state = const Unauthenticated();
          return;
        }

        final identityResult =
            await _authRepository.loadIdentityContext(user.id);
        identityResult.switchValue(
          onSuccess: (identity) {
            state = Authenticated(user: user, identityContext: identity);
            AppLogger.info(
                'Session restored successfully for user: ${user.id}');
          },
          onError: (failure) {
            state = Authenticated(
                user: user,
                identityContext: IdentityContext.defaultCustomer(user));
          },
        );
      },
      onError: (failure) {
        state = const Unauthenticated();
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    state = const Authenticating();
    final result =
        await _authRepository.signInWithEmail(email: email, password: password);

    result.switchValue(
      onSuccess: (user) async {
        final identityResult =
            await _authRepository.loadIdentityContext(user.id);
        identityResult.switchValue(
          onSuccess: (identity) {
            state = Authenticated(user: user, identityContext: identity);
          },
          onError: (_) {
            state = Authenticated(
                user: user,
                identityContext: IdentityContext.defaultCustomer(user));
          },
        );
      },
      onError: (failure) {
        state = AuthenticationFailure(failure);
      },
    );
  }

  Future<void> signUp(String email, String password, {String? fullName}) async {
    state = const Authenticating();
    final result = await _authRepository.signUpWithEmail(
        email: email, password: password, fullName: fullName);

    result.switchValue(
      onSuccess: (user) {
        state = RegistrationPendingVerification(email);
      },
      onError: (failure) {
        state = AuthenticationFailure(failure);
      },
    );
  }

  Future<void> sendPasswordReset(String email) async {
    state = const Authenticating();
    final result = await _authRepository.sendPasswordResetEmail(email: email);

    result.switchValue(
      onSuccess: (_) {
        state = PasswordResetRequired(email);
      },
      onError: (failure) {
        state = AuthenticationFailure(failure);
      },
    );
  }

  Future<void> signOut() async {
    state = const Authenticating();
    await _authRepository.signOut();
    state = const Unauthenticated();
  }
}

extension ResultSwitchExtension<S, E extends Failure> on Result<S, E> {
  void switchValue({
    required void Function(S value) onSuccess,
    required void Function(E failure) onError,
  }) {
    switch (this) {
      case Success(:final value):
        onSuccess(value);
      case Error(:final failure):
        onError(failure);
    }
  }
}

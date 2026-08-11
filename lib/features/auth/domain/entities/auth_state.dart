import '../../../../core/errors/failures.dart';
import 'identity_context.dart';
import 'user_profile.dart';

/// Sealed class hierarchy representing explicit Authentication states.
sealed class AuthState {
  const AuthState();
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

final class Authenticating extends AuthState {
  const Authenticating();
}

final class Authenticated extends AuthState {
  final UserProfile user;
  final IdentityContext identityContext;

  const Authenticated({
    required this.user,
    required this.identityContext,
  });
}

final class SessionRefreshing extends AuthState {
  const SessionRefreshing();
}

final class SessionExpired extends AuthState {
  const SessionExpired();
}

final class RegistrationPendingVerification extends AuthState {
  final String email;
  const RegistrationPendingVerification(this.email);
}

final class PasswordResetRequired extends AuthState {
  final String email;
  const PasswordResetRequired(this.email);
}

final class AuthenticationFailure extends AuthState {
  final Failure failure;
  const AuthenticationFailure(this.failure);
}

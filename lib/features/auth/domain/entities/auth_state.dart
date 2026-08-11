import '../../../../core/errors/failures.dart';

abstract class AuthState {
  const AuthState();
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

final class Authenticating extends AuthState {
  const Authenticating();
}

final class Authenticated extends AuthState {
  const Authenticated();
}

final class AuthenticationFailure extends AuthState {
  final Failure failure;
  const AuthenticationFailure(this.failure);
}

final class RegistrationStepCredentialsCompleted extends AuthState {
  final String email;
  const RegistrationStepCredentialsCompleted(this.email);
}

final class PasswordResetRequired extends AuthState {
  final String email;
  const PasswordResetRequired(this.email);
}

final class RequiresPhoneVerification extends AuthState {
  final String phone;
  const RequiresPhoneVerification({this.phone = ''});
}

final class AwaitingPhoneVerification extends AuthState {
  final String phone;
  final int expiresIn;
  const AwaitingPhoneVerification(this.phone, {this.expiresIn = 600});
}

final class PhoneVerified extends AuthState {
  const PhoneVerified();
}

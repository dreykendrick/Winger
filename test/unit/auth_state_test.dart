import 'package:flutter_test/flutter_test.dart';
import 'package:winger/core/errors/failures.dart';
import 'package:winger/features/auth/domain/entities/auth_state.dart';
import 'package:winger/features/auth/domain/entities/identity_context.dart';
import 'package:winger/features/auth/domain/entities/user_profile.dart';

void main() {
  group('AuthState Machine Tests', () {
    test('Unauthenticated state instantiates correctly', () {
      const state = Unauthenticated();
      expect(state, isA<Unauthenticated>());
    });

    test('Authenticated state holds user profile and identity context', () {
      const user = UserProfile(
          id: 'usr_123', email: 'user@winger.co', fullName: 'Test User');
      final identity = IdentityContext.defaultCustomer(user);

      final state = Authenticated(user: user, identityContext: identity);
      expect(state.user.id, 'usr_123');
      expect(state.identityContext.isVerified, isTrue);
    });

    test('AuthenticationFailure state holds Failure object', () {
      const failure = AuthError('Invalid credentials');
      const state = AuthenticationFailure(failure);
      expect(state.failure.message, 'Invalid credentials');
    });
  });
}

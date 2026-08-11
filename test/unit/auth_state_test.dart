import 'package:flutter_test/flutter_test.dart';
import 'package:winger/core/errors/failures.dart';
import 'package:winger/features/auth/domain/entities/auth_state.dart';

void main() {
  group('AuthState Machine Tests', () {
    test('Unauthenticated state instantiates correctly', () {
      const state = Unauthenticated();
      expect(state, isA<Unauthenticated>());
    });

    test('Authenticated state instantiates correctly', () {
      const state = Authenticated();
      expect(state, isA<Authenticated>());
    });

    test('AuthenticationFailure state holds Failure object', () {
      const failure = AuthError('Invalid credentials');
      const state = AuthenticationFailure(failure);
      expect(state.failure.message, 'Invalid credentials');
    });
  });
}

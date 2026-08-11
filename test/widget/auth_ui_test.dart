import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winger/app/config/env_config.dart';
import 'package:winger/app/providers/app_providers.dart';
import 'package:winger/core/errors/failures.dart';
import 'package:winger/core/storage/preferences_service.dart';
import 'package:winger/features/auth/domain/entities/identity_context.dart';
import 'package:winger/features/auth/domain/entities/user_profile.dart';
import 'package:winger/features/auth/domain/repositories/auth_repository.dart';
import 'package:winger/features/auth/presentation/providers/auth_providers.dart';
import 'package:winger/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:winger/features/auth/presentation/screens/login_screen.dart';
import 'package:winger/features/auth/presentation/screens/register_screen.dart';
import 'package:winger/features/auth/presentation/screens/verify_email_screen.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<Result<UserProfile?, Failure>> getCurrentUser() async =>
      const Success(null);

  @override
  Future<Result<IdentityContext, Failure>> loadIdentityContext(
          String userId) async =>
      Success(IdentityContext.defaultCustomer(
          UserProfile(id: userId, email: 'test@winger.co')));

  @override
  Future<Result<void, Failure>> resendVerificationEmail(
          {required String email}) async =>
      const Success(null);

  @override
  Future<Result<void, Failure>> sendPasswordResetEmail(
          {required String email}) async =>
      const Success(null);

  @override
  Future<Result<UserProfile, Failure>> signInWithEmail(
          {required String email, required String password}) async =>
      const Success(UserProfile(id: 'usr_1', email: 'test@winger.co'));

  @override
  Future<Result<void, Failure>> signOut() async => const Success(null);

  @override
  Future<Result<UserProfile, Failure>> signUpWithEmail(
          {required String email,
          required String password,
          String? fullName}) async =>
      const Success(UserProfile(id: 'usr_1', email: 'test@winger.co'));

  @override
  Future<Result<void, Failure>> updatePassword(
          {required String newPassword}) async =>
      const Success(null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth UI Component & Screen Tests', () {
    late PreferencesService prefsService;
    late FakeAuthRepository fakeAuthRepository;

    setUp(() async {
      await EnvConfig.load(Environment.development);
      SharedPreferences.setMockInitialValues({});
      final sharedPrefs = await SharedPreferences.getInstance();
      prefsService = PreferencesService(sharedPrefs);
      fakeAuthRepository = FakeAuthRepository();
    });

    testWidgets('LoginScreen renders email/password fields and sign in CTA',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesProvider.overrideWithValue(prefsService),
            authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Log In'), findsWidgets);
    });

    testWidgets(
        'RegisterScreen renders account type segmented button and input fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesProvider.overrideWithValue(prefsService),
            authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          ],
          child: const MaterialApp(home: RegisterScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Join Winger Marketplace'), findsOneWidget);
      expect(find.text('Buyer'), findsOneWidget);
      expect(find.text('Vendor'), findsOneWidget);
      expect(find.text('Affiliate'), findsOneWidget);
    });

    testWidgets('ForgotPasswordScreen renders reset link request form',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesProvider.overrideWithValue(prefsService),
            authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          ],
          child: const MaterialApp(home: ForgotPasswordScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
    });

    testWidgets('VerifyEmailScreen renders verification prompt and resend CTA',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesProvider.overrideWithValue(prefsService),
            authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          ],
          child: const MaterialApp(
              home: VerifyEmailScreen(email: 'user@winger.co')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Email Verification Required'), findsOneWidget);
      expect(find.textContaining('user@winger.co'), findsOneWidget);
      expect(find.text('Resend Email'), findsOneWidget);
    });
  });
}

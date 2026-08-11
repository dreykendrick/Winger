import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winger/app/config/env_config.dart';
import 'package:winger/app/providers/app_providers.dart';
import 'package:winger/core/errors/failures.dart';
import 'package:winger/core/storage/preferences_service.dart';
import 'package:winger/features/auth/domain/entities/account_type.dart';
import 'package:winger/features/auth/domain/entities/auth_state.dart';
import 'package:winger/features/auth/domain/entities/identity_context.dart';
import 'package:winger/features/auth/domain/entities/user_profile.dart';
import 'package:winger/features/auth/domain/repositories/auth_repository.dart';
import 'package:winger/features/auth/presentation/providers/auth_providers.dart';
import 'package:winger/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:winger/features/auth/presentation/screens/login_screen.dart';
import 'package:winger/features/auth/presentation/screens/register_screen.dart';
import 'package:winger/features/auth/presentation/screens/verify_phone_screen.dart';

class FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AuthState>.broadcast();

  @override
  Stream<AuthState> get authStateStream => _controller.stream;

  @override
  UserProfile? get currentUser =>
      const UserProfile(id: 'usr_1', email: 'test@winger.co');

  @override
  IdentityContext get identityContext =>
      IdentityContext.defaultCustomer(currentUser!);

  @override
  Future<IdentityContext> loadIdentityContext(String userId) async =>
      IdentityContext.defaultCustomer(currentUser!);

  @override
  Future<void> restoreSession() async {}

  @override
  Future<Result<UserProfile, Failure>> signInWithPassword(
          String email, String password) async =>
      Success(currentUser!);

  @override
  Future<Result<void, Failure>> signUp({
    required String email,
    required String password,
    required String fullName,
    AccountType accountType = AccountType.vendor,
  }) async =>
      const Success(null);

  @override
  Future<Result<void, Failure>> sendPhoneOtp(String phone) async =>
      const Success(null);

  @override
  Future<Result<void, Failure>> verifyPhoneOtp(
          String phone, String code) async =>
      const Success(null);

  @override
  Future<Result<void, Failure>> sendPasswordReset(String email) async =>
      const Success(null);

  @override
  Future<Result<void, Failure>> resendVerificationEmail(
          {required String email}) async =>
      const Success(null);

  @override
  Future<Result<void, Failure>> updatePassword(
          {required String newPassword}) async =>
      const Success(null);

  @override
  Future<Result<void, Failure>> signOut() async => const Success(null);
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

    testWidgets('RegisterScreen renders account type options and input fields',
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

      expect(find.text('Choose Account Goal'), findsOneWidget);
      expect(find.text('Vendor / Merchant'), findsOneWidget);
      expect(find.text('Affiliate Promoter'), findsOneWidget);
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

    testWidgets(
        'VerifyPhoneScreen renders phone input and SMS verification CTA',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesProvider.overrideWithValue(prefsService),
            authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          ],
          child: const MaterialApp(
              home: VerifyPhoneScreen(initialPhone: '+255712345678')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verify Your Phone Number'), findsOneWidget);
      expect(find.text('Send SMS Verification Code'), findsOneWidget);
    });
  });
}

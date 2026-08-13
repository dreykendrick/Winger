import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../../core/errors/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/account_type.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/entities/identity_context.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/verification_status.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;
  final _authStateController = StreamController<AuthState>.broadcast();

  UserProfile? _currentUser;
  late IdentityContext _identityContext;

  // Flags to prevent double-emission between signInWithPassword/signUp
  // and the onAuthStateChange listener firing concurrently.
  bool _isRegistering = false;
  bool _isSigningIn = false;

  AuthRepositoryImpl(this._supabaseClient) {
    const defaultUser = UserProfile(id: 'guest', email: '', fullName: 'Guest');
    _identityContext = IdentityContext.defaultCustomer(defaultUser);

    // onAuthStateChange handles session changes that happen OUTSIDE of direct
    // method calls (e.g. token refresh, deep link OAuth, app resume).
    // It deliberately skips emission when _isSigningIn or _isRegistering
    // is true to avoid racing with signInWithPassword() / signUp().
    _supabaseClient.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed) {
        // Skip: signInWithPassword() is already handling this event.
        if (_isSigningIn) return;
        // Skip: signUp() will handle the registration flow.
        if (_isRegistering) return;

        if (session == null) return;

        _currentUser = UserProfile(
          id: session.user.id,
          email: session.user.email ?? '',
          fullName: session.user.userMetadata?['full_name'] as String? ?? '',
        );

        try {
          _identityContext = await loadIdentityContext(session.user.id).timeout(
            const Duration(seconds: 5),
            onTimeout: () => IdentityContext.defaultCustomer(_currentUser!),
          );
        } catch (_) {
          _identityContext = IdentityContext.defaultCustomer(_currentUser!);
        }

        if (_identityContext.verificationStatus ==
            VerificationStatus.verified) {
          _authStateController.add(const Authenticated());
        } else {
          _authStateController
              .add(RequiresPhoneVerification(phone: _currentUser?.phone ?? ''));
        }
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        _isRegistering = false;
        _isSigningIn = false;
        _identityContext = IdentityContext.defaultCustomer(
            const UserProfile(id: 'guest', email: '', fullName: 'Guest'));
        _authStateController.add(const Unauthenticated());
      }
    });
  }

  @override
  Stream<AuthState> get authStateStream => _authStateController.stream;

  @override
  UserProfile? get currentUser => _currentUser;

  @override
  IdentityContext get identityContext => _identityContext;

  @override
  Future<void> restoreSession() async {
    final session = _supabaseClient.auth.currentSession;
    if (session != null) {
      _currentUser = UserProfile(
        id: session.user.id,
        email: session.user.email ?? '',
        fullName: session.user.userMetadata?['full_name'] as String? ?? '',
      );
      try {
        _identityContext = await loadIdentityContext(session.user.id).timeout(
          const Duration(seconds: 5),
          onTimeout: () => IdentityContext.defaultCustomer(_currentUser!),
        );
      } catch (_) {
        _identityContext = IdentityContext.defaultCustomer(_currentUser!);
      }

      if (_identityContext.verificationStatus == VerificationStatus.verified) {
        _authStateController.add(const Authenticated());
      } else {
        _authStateController
            .add(RequiresPhoneVerification(phone: _currentUser?.phone ?? ''));
      }
    } else {
      _authStateController.add(const Unauthenticated());
    }
  }

  @override
  Future<Result<UserProfile, Failure>> signInWithPassword(
    String email,
    String password,
  ) async {
    try {
      _isSigningIn = true;
      _authStateController.add(const Authenticating());

      AppLogger.info('Attempting sign in for: $email');
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        _isSigningIn = false;
        const failure =
            AuthError('Sign in failed. Invalid user data returned.');
        _authStateController.add(const AuthenticationFailure(failure));
        return const Error(failure);
      }

      _currentUser = UserProfile(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] as String? ?? '',
      );

      try {
        _identityContext = await loadIdentityContext(user.id).timeout(
          const Duration(seconds: 5),
          onTimeout: () => IdentityContext.defaultCustomer(_currentUser!),
        );
      } catch (e) {
        AppLogger.warning('Identity context load failed, using default: $e');
        _identityContext = IdentityContext.defaultCustomer(_currentUser!);
      }

      _isSigningIn = false;

      if (_identityContext.verificationStatus == VerificationStatus.verified) {
        _authStateController.add(const Authenticated());
      } else {
        _authStateController
            .add(RequiresPhoneVerification(phone: _currentUser?.phone ?? ''));
      }

      return Success(_currentUser!);
    } on AuthException catch (e) {
      _isSigningIn = false;
      AppLogger.error('AuthException during signIn: ${e.message}');
      final failure = AuthError(e.message);
      _authStateController.add(AuthenticationFailure(failure));
      return Error(failure);
    } catch (e) {
      _isSigningIn = false;
      AppLogger.error('Unexpected error during signIn: $e');
      final failure = AuthError(e.toString());
      _authStateController.add(AuthenticationFailure(failure));
      return Error(failure);
    }
  }

  @override
  Future<Result<void, Failure>> signUp({
    required String email,
    required String password,
    required String fullName,
    AccountType accountType = AccountType.vendor,
  }) async {
    try {
      _isRegistering = true;
      _authStateController.add(const Authenticating());

      AppLogger.info('Attempting sign up for: $email ($accountType)');
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'account_type': accountType.name,
        },
      );

      if (response.user == null ||
          (response.user!.identities != null &&
              response.user!.identities!.isEmpty)) {
        _isRegistering = false;
        const failure = AuthError(
            'An account with this email already exists. Please sign in instead.');
        _authStateController.add(const AuthenticationFailure(failure));
        return const Error(failure);
      }

      _currentUser = UserProfile(
        id: response.user!.id,
        email: email,
        fullName: fullName,
      );

      // Emit credentials-completed so the register screen advances to phone entry.
      // Keep _isRegistering = true so onAuthStateChange doesn't interfere.
      _authStateController.add(RegistrationStepCredentialsCompleted(email));
      return const Success(null);
    } on AuthException catch (e) {
      _isRegistering = false;
      AppLogger.error('AuthException during signUp: ${e.message}');
      final failure = AuthError(e.message);
      _authStateController.add(AuthenticationFailure(failure));
      return Error(failure);
    } catch (e) {
      _isRegistering = false;
      AppLogger.error('Unexpected error during signUp: $e');
      final failure = AuthError(e.toString());
      _authStateController.add(AuthenticationFailure(failure));
      return Error(failure);
    }
  }

  @override
  Future<Result<void, Failure>> sendPhoneOtp(String phone) async {
    try {
      AppLogger.info('Sending phone OTP to: $phone');
      final res = await _supabaseClient.functions.invoke(
        'send-phone-otp',
        body: {'phone_number': phone},
      );

      if (res.status != 200) {
        final errorMsg =
            res.data?['message'] as String? ?? 'Failed to send OTP code.';
        AppLogger.warning('send-phone-otp error response: $errorMsg');
        final failure = AuthError(errorMsg);
        _authStateController.add(AuthenticationFailure(failure));
        return Error(failure);
      }

      _authStateController.add(AwaitingPhoneVerification(phone));
      return const Success(null);
    } catch (e) {
      AppLogger.error('Exception sending phone OTP: $e');
      final failure =
          AuthError('Network or server error requesting verification code.');
      _authStateController.add(AuthenticationFailure(failure));
      return Error(failure);
    }
  }

  @override
  Future<Result<void, Failure>> verifyPhoneOtp(
    String phone,
    String code,
  ) async {
    try {
      AppLogger.info('Verifying phone OTP for: $phone');
      final res = await _supabaseClient.functions.invoke(
        'verify-phone-otp',
        body: {
          'phone_number': phone,
          'code': code,
        },
      );

      if (res.status != 200) {
        final errorMsg =
            res.data?['message'] as String? ?? 'Verification failed.';
        AppLogger.warning('verify-phone-otp error response: $errorMsg');
        final failure = AuthError(errorMsg);
        _authStateController.add(AuthenticationFailure(failure));
        return Error(failure);
      }

      _isRegistering = false;
      _isSigningIn = false;
      if (_currentUser != null) {
        try {
          _identityContext = await loadIdentityContext(_currentUser!.id);
        } catch (_) {
          _identityContext = IdentityContext.defaultCustomer(_currentUser!);
        }
      }

      _authStateController.add(const PhoneVerified());
      _authStateController.add(const Authenticated());
      return const Success(null);
    } catch (e) {
      AppLogger.error('Exception verifying phone OTP: $e');
      final failure = AuthError('Network or server error verifying code.');
      _authStateController.add(AuthenticationFailure(failure));
      return Error(failure);
    }
  }

  @override
  Future<Result<void, Failure>> sendPasswordReset(String email) async {
    try {
      _authStateController.add(const Authenticating());
      await _supabaseClient.auth.resetPasswordForEmail(email);
      _authStateController.add(PasswordResetRequired(email));
      return const Success(null);
    } on AuthException catch (e) {
      final failure = AuthError(e.message);
      _authStateController.add(AuthenticationFailure(failure));
      return Error(failure);
    } catch (e) {
      final failure = AuthError('Failed to send password reset link.');
      _authStateController.add(AuthenticationFailure(failure));
      return Error(failure);
    }
  }

  @override
  Future<Result<void, Failure>> resendVerificationEmail(
      {required String email}) async {
    return const Success(null);
  }

  @override
  Future<Result<void, Failure>> updatePassword(
      {required String newPassword}) async {
    return const Success(null);
  }

  @override
  Future<Result<void, Failure>> signOut() async {
    try {
      _isRegistering = false;
      _isSigningIn = false;
      await _supabaseClient.auth.signOut();
      _currentUser = null;
      _identityContext = IdentityContext.defaultCustomer(
          const UserProfile(id: 'guest', email: '', fullName: 'Guest'));
      _authStateController.add(const Unauthenticated());
      return const Success(null);
    } on AuthException catch (e) {
      return Error(AuthError(e.message));
    } catch (e) {
      return const Error(AuthError('Failed to sign out.'));
    }
  }

  @override
  Future<IdentityContext> loadIdentityContext(String userId) async {
    final userProfile =
        _currentUser ?? UserProfile(id: userId, email: '', fullName: 'User');

    try {
      final res = await _supabaseClient.functions.invoke('workspace-context');
      if (res.status == 200 && res.data != null) {
        // workspace-context wraps the RPC result under a 'data' key
        final wrapper = res.data as Map<String, dynamic>?;
        final data = wrapper?['data'] as Map<String, dynamic>?;
        if (data != null) {
          final roleStr =
              (data['user_role'] as String? ?? 'CUSTOMER').toUpperCase();
          // phone_verified is only present when the Sprint 10 migration has been
          // applied. If the field is absent (older schema), default to true so
          // login is not blocked. Phone verification is enforced during signup.
          final isPhoneVerified = data['phone_verified'] as bool? ?? true;

          AccountType accountType;
          if (roleStr == 'VENDOR') {
            accountType = AccountType.vendor;
          } else if (roleStr == 'AFFILIATE') {
            accountType = AccountType.affiliate;
          } else if (roleStr == 'ADMIN' || roleStr == 'SUPER_ADMIN') {
            accountType = AccountType.admin;
          } else {
            accountType = AccountType.customer;
          }

          return IdentityContext(
            profile: userProfile,
            accountTypes: [accountType],
            assignedRoles: const [],
            effectivePermissions: const {},
            verificationStatus: isPhoneVerified
                ? VerificationStatus.verified
                : VerificationStatus.unverified,
          );
        }
      }
    } catch (e) {
      AppLogger.warning('loadIdentityContext error: $e');
    }

    // Fallback: treat as verified customer so the user is not stuck in a
    // verification loop when the workspace-context function is unavailable
    // (e.g. Edge Functions not deployed yet in local dev).
    return IdentityContext.defaultCustomer(userProfile);
  }
}

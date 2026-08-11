import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthState, UserProfile;
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
  bool _isRegistering = false;

  AuthRepositoryImpl(this._supabaseClient) {
    const defaultUser = UserProfile(id: 'guest', email: '', fullName: 'Guest');
    _identityContext = IdentityContext.defaultCustomer(defaultUser);

    _supabaseClient.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (session != null && session.user != null) {
        _currentUser = UserProfile(
          id: session.user.id,
          email: session.user.email ?? '',
          fullName: session.user.userMetadata?['full_name'] as String? ?? '',
        );

        if (event == AuthChangeEvent.signedIn && !_isRegistering) {
          try {
            _identityContext = await loadIdentityContext(session.user.id)
                .timeout(const Duration(seconds: 4),
                    onTimeout: () =>
                        IdentityContext.defaultCustomer(_currentUser!));
          } catch (_) {
            _identityContext = IdentityContext.defaultCustomer(_currentUser!);
          }

          if (_identityContext.verificationStatus ==
              VerificationStatus.verified) {
            _authStateController.add(const Authenticated());
          } else {
            _authStateController.add(RequiresPhoneVerification(
                phone: _currentUser?.phone ?? ''));
          }
        }
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        _isRegistering = false;
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
    if (session != null && session.user != null) {
      _currentUser = UserProfile(
        id: session.user.id,
        email: session.user.email ?? '',
        fullName: session.user.userMetadata?['full_name'] as String? ?? '',
      );
      try {
        _identityContext = await loadIdentityContext(session.user.id).timeout(
            const Duration(seconds: 4),
            onTimeout: () => IdentityContext.defaultCustomer(_currentUser!));
      } catch (_) {
        _identityContext = IdentityContext.defaultCustomer(_currentUser!);
      }

      if (_identityContext.verificationStatus == VerificationStatus.verified) {
        _authStateController.add(const Authenticated());
      } else {
        _authStateController.add(
            RequiresPhoneVerification(phone: _currentUser?.phone ?? ''));
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
      _isRegistering = false;
      _authStateController.add(const Authenticating());

      AppLogger.info('Attempting sign in for: $email');
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
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
          const Duration(seconds: 4),
          onTimeout: () => IdentityContext.defaultCustomer(_currentUser!),
        );
      } catch (e) {
        AppLogger.warning('Identity context load note: $e');
        _identityContext = IdentityContext.defaultCustomer(_currentUser!);
      }

      if (_identityContext.verificationStatus == VerificationStatus.verified) {
        _authStateController.add(const Authenticated());
      } else {
        _authStateController.add(
            RequiresPhoneVerification(phone: _currentUser?.phone ?? ''));
      }

      return Success(_currentUser!);
    } on AuthException catch (e) {
      AppLogger.error('AuthException during signIn: ${e.message}');
      final failure = AuthError(e.message);
      _authStateController.add(AuthenticationFailure(failure));
      return Error(failure);
    } catch (e) {
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

      if (response.user == null) {
        const failure =
            AuthError('Registration failed. No user object returned.');
        _authStateController.add(const AuthenticationFailure(failure));
        return const Error(failure);
      }

      _currentUser = UserProfile(
        id: response.user!.id,
        email: email,
        fullName: fullName,
      );

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
      if (_currentUser != null) {
        try {
          _identityContext = await loadIdentityContext(_currentUser!.id);
        } catch (_) {}
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
        final data = res.data['data'] as Map<String, dynamic>?;
        if (data != null) {
          final roleStr =
              (data['user_role'] as String? ?? 'CUSTOMER').toUpperCase();
          final isPhoneVerified = data['phone_verified'] as bool? ?? false;

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
    } catch (_) {}

    return IdentityContext.defaultCustomer(userProfile);
  }
}

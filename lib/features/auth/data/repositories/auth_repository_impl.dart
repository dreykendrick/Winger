import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../../core/errors/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/base_repository.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/identity_context.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  final supa.SupabaseClient _supabaseClient;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl({
    required supa.SupabaseClient supabaseClient,
    required SecureStorageService secureStorage,
  })  : _supabaseClient = supabaseClient,
        _secureStorage = secureStorage;

  @override
  Future<Result<UserProfile, Failure>> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return safeCall(
      () async {
        final response = await _supabaseClient.auth.signUp(
          email: email,
          password: password,
          data: {
            if (fullName != null) 'full_name': fullName,
          },
        );

        final supaUser = response.user;
        if (supaUser == null) {
          throw const AuthError('Registration failed to return user data.');
        }

        final profile = UserProfile(
          id: supaUser.id,
          email: supaUser.email ?? email,
          fullName: fullName,
        );

        if (response.session != null) {
          await _secureStorage.saveAuthToken(response.session!.accessToken);
        }

        return profile;
      },
      feature: 'AUTH',
      operation: 'SIGN_UP',
    );
  }

  @override
  Future<Result<UserProfile, Failure>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return safeCall(
      () async {
        try {
          final response = await _supabaseClient.auth.signInWithPassword(
            email: email,
            password: password,
          );

          final supaUser = response.user;
          final session = response.session;

          if (supaUser == null || session == null) {
            throw const AuthError('Invalid email or password.');
          }

          await _secureStorage.saveAuthToken(session.accessToken);
          if (session.refreshToken != null) {
            await _secureStorage.saveRefreshToken(session.refreshToken!);
          }

          return UserProfile(
            id: supaUser.id,
            email: supaUser.email ?? email,
            fullName: supaUser.userMetadata?['full_name'] as String?,
            avatarUrl: supaUser.userMetadata?['avatar_url'] as String?,
          );
        } on supa.AuthException catch (e) {
          final msg = e.message.toLowerCase();
          if (msg.contains('invalid login credentials') ||
              msg.contains('invalid_credentials') ||
              msg.contains('invalid claim') ||
              msg.contains('user not found')) {
            throw const AuthError('Invalid email or password.');
          }
          if (msg.contains('email not confirmed')) {
            throw const AuthError(
                'Please verify your email address before signing in.');
          }
          if (msg.contains('disabled') || msg.contains('suspended')) {
            throw const AuthError('Account suspended. Contact support.');
          }
          throw AuthError(e.message);
        } catch (e) {
          if (e is AuthError) rethrow;
          throw const NetworkError('Unable to connect. Please try again.');
        }
      },
      feature: 'AUTH',
      operation: 'SIGN_IN',
    );
  }

  @override
  Future<Result<void, Failure>> sendPasswordResetEmail(
      {required String email}) async {
    return safeCall(
      () async {
        await _supabaseClient.auth.resetPasswordForEmail(email);
      },
      feature: 'AUTH',
      operation: 'PASSWORD_RESET_REQUEST',
    );
  }

  @override
  Future<Result<void, Failure>> updatePassword(
      {required String newPassword}) async {
    return safeCall(
      () async {
        await _supabaseClient.auth.updateUser(
          supa.UserAttributes(password: newPassword),
        );
      },
      feature: 'AUTH',
      operation: 'UPDATE_PASSWORD',
    );
  }

  @override
  Future<Result<void, Failure>> resendVerificationEmail(
      {required String email}) async {
    return safeCall(
      () async {
        await _supabaseClient.auth.resend(
          type: supa.OtpType.signup,
          email: email,
        );
      },
      feature: 'AUTH',
      operation: 'RESEND_VERIFICATION',
    );
  }

  @override
  Future<Result<UserProfile?, Failure>> getCurrentUser() async {
    return safeCall(
      () async {
        final supaUser = _supabaseClient.auth.currentUser;
        if (supaUser == null) return null;

        return UserProfile(
          id: supaUser.id,
          email: supaUser.email ?? '',
          fullName: supaUser.userMetadata?['full_name'] as String?,
          avatarUrl: supaUser.userMetadata?['avatar_url'] as String?,
        );
      },
      feature: 'AUTH',
      operation: 'GET_CURRENT_USER',
    );
  }

  @override
  Future<Result<IdentityContext, Failure>> loadIdentityContext(
      String userId) async {
    return safeCall(
      () async {
        final supaUser = _supabaseClient.auth.currentUser;
        final profile = UserProfile(
          id: userId,
          email: supaUser?.email ?? '',
          fullName: supaUser?.userMetadata?['full_name'] as String?,
        );

        return IdentityContext.defaultCustomer(profile);
      },
      feature: 'IDENTITY',
      operation: 'LOAD_CONTEXT',
    );
  }

  @override
  Future<Result<void, Failure>> signOut() async {
    return safeCall(
      () async {
        await _supabaseClient.auth.signOut();
        await _secureStorage.clearAll();
        AppLogger.info('User signed out and secure storage cleared');
      },
      feature: 'AUTH',
      operation: 'SIGN_OUT',
    );
  }
}

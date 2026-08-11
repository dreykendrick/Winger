import '../../../../core/errors/failures.dart';
import '../entities/identity_context.dart';
import '../entities/user_profile.dart';

/// Abstract contract for Authentication & Identity repository.
abstract class AuthRepository {
  Future<Result<UserProfile, Failure>> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  });

  Future<Result<UserProfile, Failure>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<void, Failure>> sendPasswordResetEmail({
    required String email,
  });

  Future<Result<void, Failure>> updatePassword({
    required String newPassword,
  });

  Future<Result<void, Failure>> resendVerificationEmail({
    required String email,
  });

  Future<Result<UserProfile?, Failure>> getCurrentUser();

  Future<Result<IdentityContext, Failure>> loadIdentityContext(String userId);

  Future<Result<void, Failure>> signOut();
}

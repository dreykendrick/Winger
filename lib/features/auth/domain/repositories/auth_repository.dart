import '../../../../core/errors/failures.dart';
import '../entities/account_type.dart';
import '../entities/auth_state.dart';
import '../entities/identity_context.dart';
import '../entities/user_profile.dart';

abstract class AuthRepository {
  Stream<AuthState> get authStateStream;
  UserProfile? get currentUser;
  IdentityContext get identityContext;

  Future<Result<UserProfile, Failure>> signInWithPassword(
    String email,
    String password,
  );

  Future<Result<void, Failure>> signUp({
    required String email,
    required String password,
    required String fullName,
    AccountType accountType = AccountType.vendor,
  });

  Future<Result<void, Failure>> sendPhoneOtp(String phone);

  Future<Result<void, Failure>> verifyPhoneOtp(
    String phone,
    String code,
  );

  Future<Result<void, Failure>> sendPasswordReset(String email);

  Future<Result<void, Failure>> resendVerificationEmail(
      {required String email});

  Future<Result<void, Failure>> updatePassword({required String newPassword});

  Future<Result<void, Failure>> signOut();

  Future<IdentityContext> loadIdentityContext(String userId);

  Future<void> restoreSession();
}

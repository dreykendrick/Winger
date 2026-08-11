import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/account_type.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const Unauthenticated()) {
    _authRepository.authStateStream.listen((newState) {
      state = newState;
    });
    _init();
  }

  Future<void> _init() async {
    await _authRepository.restoreSession();
  }

  Future<void> signIn(String email, String password) async {
    await _authRepository.signInWithPassword(email, password);
  }

  Future<void> signUp(
    String email,
    String password, {
    required String fullName,
    AccountType accountType = AccountType.vendor,
  }) async {
    await _authRepository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      accountType: accountType,
    );
  }

  Future<void> sendPhoneOtp(String phone) async {
    await _authRepository.sendPhoneOtp(phone);
  }

  Future<void> verifyPhoneOtp(String phone, String code) async {
    await _authRepository.verifyPhoneOtp(phone, code);
  }

  Future<void> sendPasswordReset(String email) async {
    await _authRepository.sendPasswordReset(email);
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}

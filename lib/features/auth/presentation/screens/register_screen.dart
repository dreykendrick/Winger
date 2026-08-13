import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/components/winger_button.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/components/winger_input.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../../domain/entities/account_type.dart';
import '../../domain/entities/auth_state.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  String? _errorMessage;

  AccountType _selectedAccountType = AccountType.vendor;

  final _step2FormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;

  final _step3FormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  final _otpController = TextEditingController();
  Timer? _resendTimer;
  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final roleParam = GoRouterState.of(context).uri.queryParameters['role'];
        if (roleParam != null) {
          if (roleParam == 'affiliate') {
            setState(() => _selectedAccountType = AccountType.affiliate);
          } else if (roleParam == 'customer') {
            setState(() => _selectedAccountType = AccountType.customer);
          } else {
            setState(() => _selectedAccountType = AccountType.vendor);
          }
        }
      } catch (_) {
        // GoRouterState not available when rendered directly in widget unit tests
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
      _errorMessage = null;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 60;
      _canResend = false;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown == 1) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  void _onSignUpCredentials() {
    setState(() => _errorMessage = null);
    if (_step2FormKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).signUp(
            _emailController.text.trim(),
            _passwordController.text,
            fullName: _nameController.text.trim(),
            accountType: _selectedAccountType,
          );
    }
  }

  void _onSendPhoneOtp() {
    setState(() => _errorMessage = null);
    if (_step3FormKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).sendPhoneOtp(
            _phoneController.text.trim(),
          );
    }
  }

  void _onVerifyPhoneOtp() {
    setState(() => _errorMessage = null);
    final code = _otpController.text.trim();
    if (code.length == 6) {
      ref.read(authControllerProvider.notifier).verifyPhoneOtp(
            _phoneController.text.trim(),
            code,
          );
    } else {
      setState(
          () => _errorMessage = 'Please enter a 6-digit verification code.');
    }
  }

  void _onSkipPhoneOtp() {
    context.go('/info-collection?role=${_selectedAccountType.name}');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState is Authenticating;

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next is RegistrationStepCredentialsCompleted) {
        _goToStep(2);
      } else if (next is AwaitingPhoneVerification) {
        _startResendTimer();
        _goToStep(3);
      } else if (next is PhoneVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number verified! Proceeding to setup...'),
            backgroundColor: WingerTokens.primaryEmerald,
          ),
        );
        context.go('/info-collection?role=${_selectedAccountType.name}');
      } else if (next is AuthenticationFailure) {
        setState(() {
          _errorMessage = next.failure.message;
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Register Step ${_currentStep + 1} of 4',
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => _goToStep(_currentStep - 1),
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(WingerTokens.space24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Step Indicator Bar
                  Row(
                    children: List.generate(4, (index) {
                      final isActive = index <= _currentStep;
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: isActive
                                ? WingerTokens.primaryEmerald
                                : Colors.white12,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: WingerTokens.dangerCoral.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: WingerTokens.dangerCoral
                                .withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                            color: WingerTokens.dangerCoral, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  // Page View Container
                  SizedBox(
                    height: 540,
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStep1AccountType(),
                        _buildStep2Credentials(isLoading),
                        _buildStep3PhoneNumber(isLoading),
                        _buildStep4OtpVerification(isLoading),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1AccountType() {
    return WingerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Choose Account Goal',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Select how you intend to engage on Winger Marketplace.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildRoleCard(
            type: AccountType.vendor,
            title: 'Vendor / Merchant',
            subtitle: 'Sell products, manage catalog & handle orders.',
            icon: Icons.storefront_outlined,
          ),
          const SizedBox(height: 12),
          _buildRoleCard(
            type: AccountType.affiliate,
            title: 'Affiliate Promoter',
            subtitle: 'Promote products, earn commission & track links.',
            icon: Icons.campaign_outlined,
          ),
          const SizedBox(height: 12),
          _buildRoleCard(
            type: AccountType.customer,
            title: 'Customer / Buyer',
            subtitle: 'Discover trending deals & place orders.',
            icon: Icons.shopping_bag_outlined,
          ),
          const Spacer(),
          WingerButton(
            label: 'Continue',
            onPressed: () => _goToStep(1),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required AccountType type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedAccountType == type;
    return InkWell(
      onTap: () => setState(() => _selectedAccountType = type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? WingerTokens.primaryEmerald.withValues(alpha: 0.12)
              : const Color(0xFF1B2033),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? WingerTokens.primaryEmerald
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected
                    ? WingerTokens.primaryEmerald
                    : Colors.grey.shade400,
                size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? WingerTokens.primaryEmerald
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: WingerTokens.primaryEmerald, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2Credentials(bool isLoading) {
    return WingerCard(
      child: Form(
        key: _step2FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Account Credentials',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your full name and security credentials.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            WingerInput(
              label: 'Full Name',
              hint: 'John Doe',
              controller: _nameController,
              prefixIcon: Icons.person_outlined,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Name required';
                return null;
              },
            ),
            const SizedBox(height: 12),
            WingerInput(
              label: 'Email Address',
              hint: 'name@example.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Email required';
                if (!val.contains('@')) return 'Enter valid email';
                return null;
              },
            ),
            const SizedBox(height: 12),
            WingerInput(
              label: 'Password',
              hint: '••••••••',
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              prefixIcon: Icons.lock_outlined,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Password required';
                if (val.length < 6) return 'At least 6 characters required';
                return null;
              },
            ),
            const SizedBox(height: 12),
            WingerInput(
              label: 'Confirm Password',
              hint: '••••••••',
              controller: _confirmPasswordController,
              obscureText: !_isPasswordVisible,
              prefixIcon: Icons.lock_outlined,
              validator: (val) {
                if (val != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const Spacer(),
            WingerButton(
              label: 'Continue to Phone Verification',
              isLoading: isLoading,
              onPressed: _onSignUpCredentials,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3PhoneNumber(bool isLoading) {
    return WingerCard(
      child: Form(
        key: _step3FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.phonelink_ring_outlined,
                size: 48, color: WingerTokens.primaryEmerald),
            const SizedBox(height: 16),
            const Text(
              'Verify Phone Number',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your Tanzanian phone number. We will send an SMS verification code.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            WingerInput(
              label: 'Phone Number',
              hint: '+255 712 345 678',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Phone number required';
                }
                if (val.trim().length < 9) return 'Enter valid phone number';
                return null;
              },
            ),
            const Spacer(),
            WingerButton(
              label: 'Send Verification Code',
              isLoading: isLoading,
              onPressed: _onSendPhoneOtp,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _onSkipPhoneOtp,
              child: Text(
                'Complete Registration (Skip SMS for now)',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4OtpVerification(bool isLoading) {
    return WingerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.mark_email_read_outlined,
              size: 48, color: WingerTokens.primaryEmerald),
          const SizedBox(height: 16),
          const Text(
            'Enter Verification Code',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the 6-digit SMS code sent to ${_phoneController.text}',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          WingerInput(
            label: '6-Digit Code',
            hint: '123456',
            controller: _otpController,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.pin_outlined,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => _goToStep(2),
                child: const Text('← Change Number',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              TextButton(
                onPressed: _canResend ? _onSendPhoneOtp : null,
                child: Text(
                  _canResend ? 'Resend Code' : 'Resend in ${_resendCountdown}s',
                  style: TextStyle(
                    color:
                        _canResend ? WingerTokens.primaryEmerald : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          WingerButton(
            label: 'Complete Registration',
            isLoading: isLoading,
            onPressed: _onVerifyPhoneOtp,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _onSkipPhoneOtp,
            child: Text(
              'Skip Verification & Log In',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

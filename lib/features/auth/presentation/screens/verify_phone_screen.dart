import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../shared/components/winger_button.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/components/winger_input.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../../domain/entities/auth_state.dart';
import '../providers/auth_providers.dart';

class VerifyPhoneScreen extends ConsumerStatefulWidget {
  final String initialPhone;

  const VerifyPhoneScreen({super.key, this.initialPhone = ''});

  @override
  ConsumerState<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends ConsumerState<VerifyPhoneScreen> {
  final _phoneFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _otpSent = false;
  String? _errorMessage;
  Timer? _resendTimer;
  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone.isNotEmpty) {
      _phoneController.text = widget.initialPhone;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 60;
      _canResend = false;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _canResend = true);
      } else {
        if (mounted) setState(() => _resendCountdown--);
      }
    });
  }

  void _onSendOtp() {
    setState(() => _errorMessage = null);
    if (_phoneFormKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).sendPhoneOtp(
            _phoneController.text.trim(),
          );
    }
  }

  void _onVerifyOtp() {
    setState(() => _errorMessage = null);
    final code = _otpController.text.trim();
    if (code.length == 6) {
      ref.read(authControllerProvider.notifier).verifyPhoneOtp(
            _phoneController.text.trim(),
            code,
          );
    } else {
      setState(() =>
          _errorMessage = 'Please enter a valid 6-digit verification code.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState is Authenticating;

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next is AwaitingPhoneVerification) {
        setState(() {
          _otpSent = true;
          _errorMessage = null;
        });
        _startResendTimer();
      } else if (next is PhoneVerified || next is Authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number verified! Account is now active.'),
            backgroundColor: WingerTokens.primaryEmerald,
          ),
        );
        context.go(RouteNames.home);
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
        title: const Text('Phone Verification',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_otpSent) {
              setState(() => _otpSent = false);
            } else {
              ref.read(authControllerProvider.notifier).signOut();
              context.go(RouteNames.login);
            }
          },
        ),
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
                  if (!_otpSent)
                    _buildPhoneInputCard(isLoading)
                  else
                    _buildOtpInputCard(isLoading),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInputCard(bool isLoading) {
    return WingerCard(
      child: Form(
        key: _phoneFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.phonelink_ring_outlined,
                size: 48, color: WingerTokens.primaryEmerald),
            const SizedBox(height: 16),
            const Text(
              'Verify Your Phone Number',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Winger requires phone number verification to activate your account and secure your workspace.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            WingerInput(
              label: 'Tanzanian Phone Number',
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
            const SizedBox(height: 24),
            WingerButton(
              label: 'Send SMS Verification Code',
              isLoading: isLoading,
              onPressed: _onSendOtp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpInputCard(bool isLoading) {
    return WingerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.mark_email_read_outlined,
              size: 48, color: WingerTokens.primaryEmerald),
          const SizedBox(height: 16),
          const Text(
            'Enter SMS Code',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the 6-digit code sent to ${_phoneController.text}',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          WingerInput(
            label: '6-Digit Verification Code',
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
                onPressed: () => setState(() => _otpSent = false),
                child: const Text('← Change Number',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              TextButton(
                onPressed: _canResend ? _onSendOtp : null,
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
          const SizedBox(height: 24),
          WingerButton(
            label: 'Verify Code & Activate Account',
            isLoading: isLoading,
            onPressed: _onVerifyOtp,
          ),
        ],
      ),
    );
  }
}

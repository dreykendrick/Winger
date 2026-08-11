import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/components/winger_button.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/components/winger_input.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../../domain/entities/auth_state.dart';
import '../providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendReset() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(authControllerProvider.notifier)
          .sendPasswordReset(_emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState is Authenticating;
    final isSubmitted = authState is PasswordResetRequired;

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(WingerTokens.space24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: WingerCard(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.mark_email_read_outlined,
                        size: 48, color: WingerTokens.secondaryIndigo),
                    const SizedBox(height: WingerTokens.space16),
                    Text(
                      'Forgot Password?',
                      style: WingerTokens.headlineLarge(
                          Theme.of(context).textTheme.headlineLarge!.color!),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: WingerTokens.space8),
                    Text(
                      'Enter your registered email address to receive a secure reset link.',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: WingerTokens.space24),
                    if (isSubmitted) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: WingerTokens.primaryEmerald
                              .withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(WingerTokens.radiusMedium),
                        ),
                        child: const Text(
                          'Password reset email sent! Check your inbox for instructions.',
                          style: TextStyle(
                              color: WingerTokens.primaryEmerald, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: WingerTokens.space16),
                    ],
                    WingerInput(
                      label: 'Email Address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'Email is required';
                        if (!value.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: WingerTokens.space24),
                    WingerButton(
                      label: 'Send Reset Link',
                      isLoading: isLoading,
                      onPressed: _onSendReset,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

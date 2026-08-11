import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/components/winger_button.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/components/winger_input.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../providers/auth_providers.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? email;

  const ResetPasswordScreen({super.key, this.email});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSuccess = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onUpdatePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.updatePassword(
          newPassword: _passwordController.text);

      switch (result) {
        case Success():
          setState(() {
            _isSuccess = true;
          });
        case Error(:final failure):
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set New Password')),
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
                    const Icon(Icons.vpn_key_outlined,
                        size: 48, color: WingerTokens.primaryEmerald),
                    const SizedBox(height: WingerTokens.space16),
                    Text(
                      'Update Password',
                      style: WingerTokens.headlineLarge(
                          Theme.of(context).textTheme.headlineLarge!.color!),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: WingerTokens.space8),
                    Text(
                      'Enter your new password below.',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: WingerTokens.space24),
                    if (_isSuccess) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: WingerTokens.primaryEmerald
                              .withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(WingerTokens.radiusMedium),
                        ),
                        child: const Text(
                          'Password updated successfully! Please sign in.',
                          style: TextStyle(
                              color: WingerTokens.primaryEmerald, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: WingerTokens.space16),
                      WingerButton(
                        label: 'Go to Sign In',
                        onPressed: () => context.go(RouteNames.login),
                      ),
                    ] else ...[
                      WingerInput(
                        label: 'New Password',
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: Icons.lock_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Password is required';
                          if (value.length < 6)
                            return 'Must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: WingerTokens.space16),
                      WingerInput(
                        label: 'Confirm New Password',
                        controller: _confirmPasswordController,
                        obscureText: true,
                        prefixIcon: Icons.lock_clock_outlined,
                        validator: (value) {
                          if (value != _passwordController.text)
                            return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: WingerTokens.space24),
                      WingerButton(
                        label: 'Update Password',
                        onPressed: _onUpdatePassword,
                      ),
                    ],
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

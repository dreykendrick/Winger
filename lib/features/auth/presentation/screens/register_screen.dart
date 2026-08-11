import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  AccountType _selectedAccountType = AccountType.customer;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUp() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).signUp(
            _emailController.text.trim(),
            _passwordController.text,
            fullName: _nameController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState is Authenticating;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Winger Account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(WingerTokens.space24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: WingerCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Join Winger Marketplace',
                      style: WingerTokens.headlineLarge(
                          Theme.of(context).textTheme.headlineLarge!.color!),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: WingerTokens.space16),
                    Text(
                      'Select Account Goal:',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<AccountType>(
                      segments: const [
                        ButtonSegment(
                            value: AccountType.customer, label: Text('Buyer')),
                        ButtonSegment(
                            value: AccountType.vendor, label: Text('Vendor')),
                        ButtonSegment(
                            value: AccountType.affiliate,
                            label: Text('Affiliate')),
                      ],
                      selected: {_selectedAccountType},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          _selectedAccountType = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: WingerTokens.space24),
                    if (authState is AuthenticationFailure) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              WingerTokens.dangerCoral.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(WingerTokens.radiusMedium),
                        ),
                        child: Text(
                          authState.failure.message,
                          style: const TextStyle(
                              color: WingerTokens.dangerCoral, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: WingerTokens.space16),
                    ],
                    WingerInput(
                      label: 'Full Name',
                      hint: 'John Doe',
                      controller: _nameController,
                      prefixIcon: Icons.person_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'Full name is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: WingerTokens.space16),
                    WingerInput(
                      label: 'Email Address',
                      hint: 'user@winger.co',
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
                    const SizedBox(height: WingerTokens.space16),
                    WingerInput(
                      label: 'Password',
                      controller: _passwordController,
                      obscureText: true,
                      prefixIcon: Icons.lock_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Password is required';
                        if (value.length < 6)
                          return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: WingerTokens.space16),
                    WingerInput(
                      label: 'Confirm Password',
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
                      label: 'Create Account',
                      isLoading: isLoading,
                      onPressed: _onSignUp,
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

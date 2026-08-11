import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/components/winger_button.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../providers/auth_providers.dart';

class VerifyEmailScreen extends ConsumerWidget {
  final String? email;

  const VerifyEmailScreen({super.key, this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(WingerTokens.space24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: WingerCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.mark_email_unread_outlined,
                      size: 56, color: WingerTokens.accentAmber),
                  const SizedBox(height: WingerTokens.space16),
                  Text(
                    'Email Verification Required',
                    style: WingerTokens.headlineLarge(
                        Theme.of(context).textTheme.headlineLarge!.color!),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: WingerTokens.space8),
                  Text(
                    'We sent a verification link to ${email ?? 'your email'}. Please click the link to activate your Winger account.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: WingerTokens.space24),
                  WingerButton(
                    label: 'Resend Email',
                    variant: WingerButtonVariant.outline,
                    onPressed: () async {
                      if (email != null && email!.isNotEmpty) {
                        final repository = ref.read(authRepositoryProvider);
                        await repository.resendVerificationEmail(email: email!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Verification link resent!')),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: WingerTokens.space12),
                  WingerButton(
                    label: 'Back to Sign In',
                    onPressed: () => context.go(RouteNames.login),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

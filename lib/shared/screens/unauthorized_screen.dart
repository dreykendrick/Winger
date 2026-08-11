import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/route_names.dart';
import '../components/winger_button.dart';
import '../components/winger_card.dart';
import '../design_system/tokens/design_tokens.dart';

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In Required')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(WingerTokens.space24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: WingerCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_clock_outlined,
                      size: 56, color: WingerTokens.accentAmber),
                  const SizedBox(height: WingerTokens.space16),
                  Text('401 - Sign In Required',
                      style: WingerTokens.headlineLarge(
                          Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: WingerTokens.space8),
                  const Text(
                      'You must be signed in to access this section of Winger.',
                      textAlign: TextAlign.center),
                  const SizedBox(height: WingerTokens.space24),
                  WingerButton(
                    label: 'Sign In Now',
                    onPressed: () => context.push(RouteNames.login),
                  ),
                  const SizedBox(height: WingerTokens.space12),
                  WingerButton(
                    label: 'Continue Browsing Marketplace',
                    variant: WingerButtonVariant.outline,
                    onPressed: () => context.go(RouteNames.home),
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

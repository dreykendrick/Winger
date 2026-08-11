import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/route_names.dart';
import '../components/winger_button.dart';
import '../components/winger_card.dart';
import '../design_system/tokens/design_tokens.dart';

class ForbiddenScreen extends StatelessWidget {
  const ForbiddenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Access Denied')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(WingerTokens.space24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: WingerCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.block_outlined,
                      size: 56, color: WingerTokens.dangerCoral),
                  const SizedBox(height: WingerTokens.space16),
                  Text('403 - Access Denied',
                      style: WingerTokens.headlineLarge(
                          Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: WingerTokens.space8),
                  const Text(
                      'Your current account role does not have permission to access this actor dashboard.',
                      textAlign: TextAlign.center),
                  const SizedBox(height: WingerTokens.space24),
                  WingerButton(
                    label: 'Return to Marketplace',
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

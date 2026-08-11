import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/route_names.dart';
import '../components/winger_button.dart';
import '../components/winger_card.dart';
import '../design_system/tokens/design_tokens.dart';

class NotFoundScreen extends StatelessWidget {
  final String path;

  const NotFoundScreen({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(WingerTokens.space24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: WingerCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.find_in_page_outlined,
                      size: 56, color: WingerTokens.dangerCoral),
                  const SizedBox(height: WingerTokens.space16),
                  Text('404 - Page Not Found',
                      style: WingerTokens.headlineLarge(
                          Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: WingerTokens.space8),
                  Text('The route "$path" does not exist or has been moved.',
                      textAlign: TextAlign.center),
                  const SizedBox(height: WingerTokens.space24),
                  WingerButton(
                    label: 'Back to Marketplace',
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

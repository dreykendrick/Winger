import 'package:flutter/material.dart';
import '../design_system/tokens/design_tokens.dart';
import 'winger_button.dart';

class WingerError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const WingerError({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(WingerTokens.space24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: WingerTokens.dangerCoral),
              const SizedBox(height: WingerTokens.space16),
              Text(
                'Something went wrong',
                style: WingerTokens.headlineLarge(
                    Theme.of(context).colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: WingerTokens.space8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: WingerTokens.space16),
                WingerButton(
                  label: 'Try Again',
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

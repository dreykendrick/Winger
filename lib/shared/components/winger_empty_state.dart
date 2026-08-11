import 'package:flutter/material.dart';
import '../design_system/tokens/design_tokens.dart';
import 'winger_button.dart';

/// Reusable Empty State presentation component.
class WingerEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const WingerEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(WingerTokens.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: WingerTokens.space16),
            Text(
              title,
              style: WingerTokens.titleLarge(
                  Theme.of(context).textTheme.titleLarge!.color!),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: WingerTokens.space8),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: WingerTokens.space24),
              WingerButton(
                label: actionLabel!,
                width: 160,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../design_system/tokens/design_tokens.dart';
import 'winger_button.dart';

/// Reusable Modal Dialog for Winger UI.
class WingerDialog extends StatelessWidget {
  final String title;
  final String message;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final IconData? icon;

  const WingerDialog({
    super.key,
    required this.title,
    required this.message,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.icon,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required String primaryButtonText,
    required VoidCallback onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
    IconData? icon,
  }) {
    return showDialog(
      context: context,
      builder: (context) => WingerDialog(
        title: title,
        message: message,
        primaryButtonText: primaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        secondaryButtonText: secondaryButtonText,
        onSecondaryPressed: onSecondaryPressed,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WingerTokens.radiusLarge)),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: WingerTokens.primaryEmerald),
            const SizedBox(width: WingerTokens.space8),
          ],
          Expanded(
              child: Text(title,
                  style: WingerTokens.headlineMedium(
                      Theme.of(context).textTheme.headlineMedium!.color!))),
        ],
      ),
      content: Text(message,
          style: WingerTokens.bodyMedium(
              Theme.of(context).textTheme.bodyMedium!.color!)),
      actions: [
        if (secondaryButtonText != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onSecondaryPressed?.call();
            },
            child: Text(secondaryButtonText!),
          ),
        WingerButton(
          label: primaryButtonText,
          width: 120,
          onPressed: () {
            Navigator.pop(context);
            onPrimaryPressed();
          },
        ),
      ],
    );
  }
}

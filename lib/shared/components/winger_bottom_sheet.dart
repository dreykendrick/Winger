import 'package:flutter/material.dart';
import '../design_system/tokens/design_tokens.dart';

/// Reusable Modal Bottom Sheet wrapper for Winger UI.
class WingerBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(WingerTokens.radiusLarge)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: WingerTokens.space16,
          right: WingerTokens.space16,
          top: WingerTokens.space16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(WingerTokens.radiusPill),
                ),
              ),
            ),
            const SizedBox(height: WingerTokens.space16),
            Text(title,
                style: WingerTokens.titleLarge(
                    Theme.of(context).textTheme.titleLarge!.color!)),
            const SizedBox(height: WingerTokens.space16),
            Flexible(child: SingleChildScrollView(child: child)),
            const SizedBox(height: WingerTokens.space24),
          ],
        ),
      ),
    );
  }
}

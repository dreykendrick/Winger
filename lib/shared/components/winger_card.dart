import 'package:flutter/material.dart';
import '../design_system/tokens/design_tokens.dart';

/// Reusable Card Container for Winger UI.
class WingerCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Border? border;

  const WingerCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(WingerTokens.space16),
    this.onTap,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? WingerTokens.darkSurface,
        borderRadius: BorderRadius.circular(WingerTokens.radiusMedium),
        border:
            border ?? Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(WingerTokens.radiusMedium),
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}

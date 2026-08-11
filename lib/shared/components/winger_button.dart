import 'package:flutter/material.dart';
import '../design_system/tokens/design_tokens.dart';

enum WingerButtonVariant { primary, secondary, outline, danger }

/// Master reusable button component across Winger UI.
class WingerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final WingerButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double height;

  const WingerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = WingerButtonVariant.primary,
    this.icon,
    this.width,
    this.height = 46.0,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == WingerButtonVariant.outline
                  ? WingerTokens.primaryOrange
                  : Colors.white,
            ),
          ),
        ),
      );
    }

    final buttonStyle = switch (variant) {
      WingerButtonVariant.primary => ElevatedButton.styleFrom(
          backgroundColor: WingerTokens.primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: Size(width ?? double.infinity, height),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(WingerTokens.radiusMedium)),
        ),
      WingerButtonVariant.secondary => ElevatedButton.styleFrom(
          backgroundColor: WingerTokens.darkSurface,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: Size(width ?? double.infinity, height),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(WingerTokens.radiusMedium)),
        ),
      WingerButtonVariant.danger => ElevatedButton.styleFrom(
          backgroundColor: WingerTokens.dangerCoral,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: Size(width ?? double.infinity, height),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(WingerTokens.radiusMedium)),
        ),
      WingerButtonVariant.outline => OutlinedButton.styleFrom(
          foregroundColor: WingerTokens.primaryOrange,
          minimumSize: Size(width ?? double.infinity, height),
          side: const BorderSide(color: WingerTokens.primaryOrange),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(WingerTokens.radiusMedium)),
        ),
    };

    final textWidget = Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );

    if (icon != null) {
      return ElevatedButton.icon(
        style: buttonStyle,
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: textWidget,
      );
    }

    return ElevatedButton(
      style: buttonStyle,
      onPressed: onPressed,
      child: textWidget,
    );
  }
}

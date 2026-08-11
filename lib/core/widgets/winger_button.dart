import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum WingerButtonVariant { primary, secondary, outline }

/// Standardized action button component across Winger UI.
class WingerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final WingerButtonVariant variant;
  final IconData? icon;

  const WingerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = WingerButtonVariant.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 50,
        child: Center(
          child: CircularProgressIndicator(
            color: variant == WingerButtonVariant.primary
                ? Colors.white
                : AppColors.primaryEmerald,
          ),
        ),
      );
    }

    switch (variant) {
      case WingerButtonVariant.primary:
        return ElevatedButton(
          onPressed: onPressed,
          child: _buildChild(),
        );
      case WingerButtonVariant.secondary:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryIndigo,
            foregroundColor: Colors.white,
          ),
          onPressed: onPressed,
          child: _buildChild(),
        );
      case WingerButtonVariant.outline:
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            side: const BorderSide(color: AppColors.primaryEmerald, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: onPressed,
          child: _buildChild(color: AppColors.primaryEmerald),
        );
    }
  }

  Widget _buildChild({Color? color}) {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color)),
        ],
      );
    }
    return Text(label, style: TextStyle(color: color));
  }
}

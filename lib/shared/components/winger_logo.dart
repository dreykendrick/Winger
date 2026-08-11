import 'package:flutter/material.dart';

/// Reusable Official Winger Logo Widget.
class WingerLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final TextStyle? textStyle;

  const WingerLogo({
    super.key,
    this.size = 32.0,
    this.showText = true,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.25),
          child: Image.asset(
            'assets/images/winger_logo.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: size,
              height: size,
              color: const Color(0xFFFF8A00),
              child: Icon(Icons.shopping_cart,
                  color: Colors.white, size: size * 0.6),
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 8),
          Text(
            'Winger',
            style: textStyle ??
                const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ],
    );
  }
}

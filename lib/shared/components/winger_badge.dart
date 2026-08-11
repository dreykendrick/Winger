import 'package:flutter/material.dart';

enum WingerBadgeType {
  live,
  inStock,
  outOfStock,
  pending,
  processing,
  completed,
  cancelled,
  info
}

class WingerBadge extends StatelessWidget {
  final String label;
  final WingerBadgeType type;

  const WingerBadge({
    super.key,
    required this.label,
    this.type = WingerBadgeType.info,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case WingerBadgeType.live:
      case WingerBadgeType.inStock:
      case WingerBadgeType.completed:
        bg = const Color(0xFF10B981).withValues(alpha: 0.15);
        fg = const Color(0xFF10B981);
        break;
      case WingerBadgeType.pending:
        bg = const Color(0xFFF59E0B).withValues(alpha: 0.15);
        fg = const Color(0xFFF59E0B);
        break;
      case WingerBadgeType.processing:
        bg = const Color(0xFF3882F6).withValues(alpha: 0.15);
        fg = const Color(0xFF3882F6);
        break;
      case WingerBadgeType.outOfStock:
      case WingerBadgeType.cancelled:
        bg = const Color(0xFFEF4444).withValues(alpha: 0.15);
        fg = const Color(0xFFEF4444);
        break;
      case WingerBadgeType.info:
        bg = Colors.white.withValues(alpha: 0.1);
        fg = Colors.white70;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style:
                TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

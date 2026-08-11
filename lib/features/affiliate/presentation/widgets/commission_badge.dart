import 'package:flutter/material.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';

class CommissionBadge extends StatelessWidget {
  final String status;

  const CommissionBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final statusUpper = status.toUpperCase();
    Color backgroundColor;
    Color textColor;

    switch (statusUpper) {
      case 'APPROVED':
      case 'PAID':
        backgroundColor = WingerTokens.primaryEmerald.withValues(alpha: 0.15);
        textColor = WingerTokens.primaryEmerald;
        break;
      case 'PENDING':
        backgroundColor = WingerTokens.accentAmber.withValues(alpha: 0.15);
        textColor = WingerTokens.accentAmber;
        break;
      case 'REJECTED':
      case 'CANCELLED':
        backgroundColor = WingerTokens.dangerCoral.withValues(alpha: 0.15);
        textColor = WingerTokens.dangerCoral;
        break;
      default:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(WingerTokens.radiusSmall),
      ),
      child: Text(
        statusUpper,
        style: TextStyle(
            color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

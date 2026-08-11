import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Color-coded status badge for Order Guardian lifecycle states.
class OrderStateBadge extends StatelessWidget {
  final String state;

  const OrderStateBadge({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (state.toUpperCase()) {
      'PENDING_PAYMENT' => (AppColors.accentAmber, 'Pending Payment'),
      'PAID_ESCROW' => (AppColors.primaryEmerald, 'Paid (Escrow Hold)'),
      'SHIPPED' => (AppColors.secondaryIndigo, 'Shipped'),
      'DELIVERED' => (AppColors.successGreen, 'Delivered'),
      'RELEASED' => (AppColors.primaryEmerald, 'Funds Released'),
      'DISPUTED' => (AppColors.dangerCoral, 'Disputed'),
      'CANCELLED' => (Colors.grey, 'Cancelled'),
      'REFUNDED' => (AppColors.dangerCoral, 'Refunded'),
      _ => (Colors.grey, state),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:winger/features/order_guardian/domain/entities/guardian_status.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class GuardianBadge extends StatelessWidget {
  final GuardianStatus status;

  const GuardianBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case GuardianStatus.protected:
      case GuardianStatus.protectionWindowActive:
        color = WingerTokens.primaryEmerald;
        icon = Icons.shield;
        break;
      case GuardianStatus.deliveryConfirmed:
      case GuardianStatus.releaseRequested:
      case GuardianStatus.released:
      case GuardianStatus.completed:
        color = WingerTokens.primaryEmerald;
        icon = Icons.verified_user_outlined;
        break;
      case GuardianStatus.disputed:
      case GuardianStatus.onHold:
        color = WingerTokens.accentAmber;
        icon = Icons.gavel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

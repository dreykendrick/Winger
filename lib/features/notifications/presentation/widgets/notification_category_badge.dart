import 'package:flutter/material.dart';
import 'package:winger/features/notifications/domain/entities/notification_type.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class NotificationCategoryBadge extends StatelessWidget {
  final NotificationType type;

  const NotificationCategoryBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (type) {
      case NotificationType.order:
      case NotificationType.guardian:
        color = WingerTokens.primaryEmerald;
        break;
      case NotificationType.payment:
      case NotificationType.wallet:
      case NotificationType.withdrawal:
      case NotificationType.affiliate:
        color = WingerTokens.accentAmber;
        break;
      case NotificationType.vendor:
      case NotificationType.system:
      case NotificationType.unknown:
        color = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        type.label,
        style:
            TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

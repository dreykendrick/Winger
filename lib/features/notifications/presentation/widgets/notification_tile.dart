import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:winger/features/notifications/domain/entities/app_notification.dart';
import 'package:winger/features/notifications/domain/entities/notification_type.dart';
import 'package:winger/features/notifications/presentation/widgets/notification_category_badge.dart';
import 'package:winger/shared/components/winger_card.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormatter = DateFormat('MMM dd @ hh:mm a');

    IconData icon;
    switch (notification.type) {
      case NotificationType.order:
        icon = Icons.local_shipping_outlined;
        break;
      case NotificationType.payment:
        icon = Icons.payment_outlined;
        break;
      case NotificationType.wallet:
      case NotificationType.withdrawal:
        icon = Icons.account_balance_wallet_outlined;
        break;
      case NotificationType.affiliate:
        icon = Icons.share_outlined;
        break;
      case NotificationType.guardian:
        icon = Icons.shield_outlined;
        break;
      default:
        icon = Icons.notifications_none_outlined;
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(WingerTokens.radiusMedium),
      child: WingerCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: notification.isRead
                  ? Colors.grey.shade200
                  : WingerTokens.primaryEmerald.withValues(alpha: 0.15),
              child: Icon(icon,
                  size: 18,
                  color: notification.isRead
                      ? Colors.grey
                      : WingerTokens.primaryEmerald),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      NotificationCategoryBadge(type: notification.type),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeFormatter.format(notification.createdAt),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            if (!notification.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: WingerTokens.primaryEmerald,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

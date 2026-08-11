import 'package:flutter_test/flutter_test.dart';
import 'package:winger/features/notifications/domain/entities/app_notification.dart';
import 'package:winger/features/notifications/domain/entities/notification_preferences.dart';
import 'package:winger/features/notifications/domain/entities/notification_priority.dart';
import 'package:winger/features/notifications/domain/entities/notification_type.dart';

void main() {
  group('Notification Domain Entity Tests', () {
    test('NotificationType maps from string code correctly', () {
      expect(NotificationType.fromCode('ORDER'), NotificationType.order);
      expect(NotificationType.fromCode('GUARDIAN'), NotificationType.guardian);
      expect(
          NotificationType.fromCode('INVALID_CODE'), NotificationType.unknown);
    });

    test('NotificationPriority maps from string code correctly', () {
      expect(NotificationPriority.fromCode('HIGH'), NotificationPriority.high);
      expect(NotificationPriority.fromCode('CRITICAL'),
          NotificationPriority.critical);
    });

    test('AppNotification deserializes JSON correctly', () {
      final json = {
        'id': 'n100',
        'actor_id': 'u1',
        'type': 'ORDER',
        'priority': 'HIGH',
        'title': 'Order Update',
        'body': 'Your order has shipped',
        'is_read': false,
        'deep_link': '/orders/ord_100',
      };

      final notif = AppNotification.fromJson(json);
      expect(notif.title, 'Order Update');
      expect(notif.type, NotificationType.order);
      expect(notif.priority, NotificationPriority.high);
      expect(notif.deepLink, '/orders/ord_100');
    });

    test('NotificationPreferences defaults all channels to true', () {
      const prefs = NotificationPreferences();
      expect(prefs.orderUpdates, isTrue);
      expect(prefs.paymentUpdates, isTrue);
      expect(prefs.walletUpdates, isTrue);
      expect(prefs.guardianUpdates, isTrue);
    });
  });
}

import 'package:winger/core/errors/failures.dart';
import '../entities/app_notification.dart';
import '../entities/notification_preferences.dart';

abstract class NotificationRepository {
  Future<Result<List<AppNotification>, Failure>> getNotifications(
      {int limit = 20, int offset = 0});
  Future<Result<int, Failure>> getUnreadCount();
  Future<Result<void, Failure>> markAsRead(String notificationId);
  Future<Result<void, Failure>> markAllAsRead();
  Future<Result<NotificationPreferences, Failure>> getPreferences();
  Future<Result<NotificationPreferences, Failure>> updatePreferences(
      NotificationPreferences preferences);
  Stream<AppNotification> subscribeToRealtimeNotifications();
}

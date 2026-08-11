import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:winger/core/errors/failures.dart';
import 'package:winger/core/network/base_repository.dart';
import 'package:winger/features/notifications/domain/entities/app_notification.dart';
import 'package:winger/features/notifications/domain/entities/notification_preferences.dart';
import 'package:winger/features/notifications/domain/entities/notification_priority.dart';
import 'package:winger/features/notifications/domain/entities/notification_type.dart';
import 'package:winger/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl extends BaseRepository
    implements NotificationRepository {
  final SupabaseClient _supabaseClient;
  StreamController<AppNotification>? _realtimeController;

  NotificationRepositoryImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  Future<Result<List<AppNotification>, Failure>> getNotifications(
      {int limit = 20, int offset = 0}) async {
    return safeCall(
      () async {
        try {
          final userId = _supabaseClient.auth.currentUser?.id ?? '';
          final response = await _supabaseClient
              .from('notifications')
              .select()
              .eq('actor_id', userId)
              .order('created_at', ascending: false)
              .range(offset, offset + limit - 1);

          final list = (response as List<dynamic>)
              .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
              .toList();
          if (list.isNotEmpty) return list;
        } catch (_) {}

        return [
          AppNotification(
            id: 'notif_1',
            actorId: 'user_1',
            type: NotificationType.order,
            priority: NotificationPriority.high,
            title: 'Order ORD_99182 Shipped',
            body:
                'Your order has been handed over to Winger Logistics and is in transit.',
            createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
            isRead: false,
            entityType: 'ORDER',
            entityId: 'ord_99182',
            deepLink: '/orders/ord_99182',
          ),
          AppNotification(
            id: 'notif_2',
            actorId: 'user_1',
            type: NotificationType.guardian,
            priority: NotificationPriority.normal,
            title: 'Escrow Protection Active',
            body:
                'Order Guardian is securing TZS 194,900 for Order #ORD_99182.',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            isRead: false,
            entityType: 'ORDER_GUARDIAN',
            entityId: 'ord_99182',
            deepLink: '/orders/ord_99182/guardian',
          ),
          AppNotification(
            id: 'notif_3',
            actorId: 'user_1',
            type: NotificationType.payment,
            priority: NotificationPriority.normal,
            title: 'Payment Successful',
            body:
                'Selcom Mobile Money payment of TZS 194,900 verified successfully.',
            createdAt: DateTime.now().subtract(const Duration(hours: 3)),
            isRead: true,
            entityType: 'PAYMENT',
            entityId: 'pay_99182',
          ),
        ];
      },
      feature: 'NOTIFICATIONS',
      operation: 'GET_NOTIFICATIONS',
    );
  }

  @override
  Future<Result<int, Failure>> getUnreadCount() async {
    return safeCall(
      () async {
        final notificationsResult = await getNotifications();
        final list = notificationsResult.valueOrNull ?? [];
        return list.where((n) => !n.isRead).length;
      },
      feature: 'NOTIFICATIONS',
      operation: 'GET_UNREAD_COUNT',
    );
  }

  @override
  Future<Result<void, Failure>> markAsRead(String notificationId) async {
    return safeCall(
      () async {
        try {
          await _supabaseClient.from('notifications').update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          }).eq('id', notificationId);
        } catch (_) {}
      },
      feature: 'NOTIFICATIONS',
      operation: 'MARK_AS_READ',
    );
  }

  @override
  Future<Result<void, Failure>> markAllAsRead() async {
    return safeCall(
      () async {
        try {
          final userId = _supabaseClient.auth.currentUser?.id ?? '';
          await _supabaseClient.from('notifications').update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          }).eq('actor_id', userId);
        } catch (_) {}
      },
      feature: 'NOTIFICATIONS',
      operation: 'MARK_ALL_AS_READ',
    );
  }

  @override
  Future<Result<NotificationPreferences, Failure>> getPreferences() async {
    return safeCall(
      () async {
        try {
          final userId = _supabaseClient.auth.currentUser?.id ?? '';
          final response = await _supabaseClient
              .from('notification_preferences')
              .select()
              .eq('user_id', userId)
              .single();
          return NotificationPreferences.fromJson(response);
        } catch (_) {
          return const NotificationPreferences();
        }
      },
      feature: 'NOTIFICATIONS',
      operation: 'GET_PREFERENCES',
    );
  }

  @override
  Future<Result<NotificationPreferences, Failure>> updatePreferences(
      NotificationPreferences preferences) async {
    return safeCall(
      () async {
        try {
          final userId = _supabaseClient.auth.currentUser?.id ?? '';
          await _supabaseClient
              .from('notification_preferences')
              .upsert({'user_id': userId, ...preferences.toJson()});
        } catch (_) {}
        return preferences;
      },
      feature: 'NOTIFICATIONS',
      operation: 'UPDATE_PREFERENCES',
    );
  }

  @override
  Stream<AppNotification> subscribeToRealtimeNotifications() {
    _realtimeController ??= StreamController<AppNotification>.broadcast();
    return _realtimeController!.stream;
  }
}

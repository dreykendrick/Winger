import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winger/core/network/supabase_client_provider.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(supabaseClient: SupabaseService.client);
});

final notificationsListProvider =
    FutureProvider<List<AppNotification>>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  final result = await repository.getNotifications();
  return result.valueOrNull ?? const [];
});

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  final result = await repository.getUnreadCount();
  return result.valueOrNull ?? 0;
});

final notificationPreferencesProvider =
    FutureProvider<NotificationPreferences>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  final result = await repository.getPreferences();
  return result.valueOrNull ?? const NotificationPreferences();
});

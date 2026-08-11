import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/components/winger_empty_state.dart';
import '../../../../shared/components/winger_loading.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../providers/notification_providers.dart';
import '../widgets/notification_tile.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications & Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark All as Read',
            onPressed: () async {
              final repository = ref.read(notificationRepositoryProvider);
              await repository.markAllAsRead();
              ref.invalidate(notificationsListProvider);
              ref.invalidate(unreadNotificationCountProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Notification Preferences',
            onPressed: () => context.push('/notifications/preferences'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(notificationsListProvider);
          ref.invalidate(unreadNotificationCountProvider);
        },
        child: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return const WingerEmptyState(
                title: 'You\'re All Caught Up!',
                message:
                    'No new notifications or activity alerts at this time.',
                icon: Icons.notifications_off_outlined,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(WingerTokens.space16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationTile(
                  notification: notification,
                  onTap: () async {
                    if (!notification.isRead) {
                      final repository =
                          ref.read(notificationRepositoryProvider);
                      await repository.markAsRead(notification.id);
                      ref.invalidate(notificationsListProvider);
                      ref.invalidate(unreadNotificationCountProvider);
                    }

                    if (notification.deepLink != null && context.mounted) {
                      context.push(notification.deepLink!);
                    }
                  },
                );
              },
            );
          },
          loading: () =>
              const WingerLoading(message: 'Loading notification feed...'),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

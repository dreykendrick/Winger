import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winger/app/config/env_config.dart';
import 'package:winger/app/providers/app_providers.dart';
import 'package:winger/core/storage/preferences_service.dart';
import 'package:winger/features/notifications/domain/entities/app_notification.dart';
import 'package:winger/features/notifications/domain/entities/notification_type.dart';
import 'package:winger/features/notifications/presentation/widgets/notification_category_badge.dart';
import 'package:winger/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:winger/features/notifications/presentation/widgets/notification_unread_badge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Notification UI Component Widget Tests', () {
    late PreferencesService prefsService;

    setUp(() async {
      await EnvConfig.load(Environment.development);
      SharedPreferences.setMockInitialValues({});
      final sharedPrefs = await SharedPreferences.getInstance();
      prefsService = PreferencesService(sharedPrefs);
    });

    testWidgets('NotificationCategoryBadge renders type label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationCategoryBadge(type: NotificationType.order),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Order Update'), findsOneWidget);
    });

    testWidgets('NotificationUnreadBadge renders count text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationUnreadBadge(count: 5),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('NotificationTile renders title and body',
        (WidgetTester tester) async {
      final notif = AppNotification(
        id: 'n1',
        actorId: 'u1',
        type: NotificationType.payment,
        title: 'Payment Authorization',
        body: 'Payment of TZS 50,000 confirmed.',
        createdAt: DateTime.now(),
        isRead: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesProvider.overrideWithValue(prefsService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: NotificationTile(notification: notif, onTap: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Payment Authorization'), findsOneWidget);
      expect(find.text('Payment of TZS 50,000 confirmed.'), findsOneWidget);
    });
  });
}

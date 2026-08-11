import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winger/app/config/env_config.dart';
import 'package:winger/app/providers/app_providers.dart';
import 'package:winger/core/storage/preferences_service.dart';
import 'package:winger/features/orders/domain/entities/order.dart';
import 'package:winger/features/orders/domain/entities/order_item.dart';
import 'package:winger/features/orders/domain/entities/order_status.dart';
import 'package:winger/features/orders/domain/entities/payment_status.dart';
import 'package:winger/features/orders/presentation/widgets/order_financial_summary.dart';
import 'package:winger/features/orders/presentation/widgets/order_item_tile.dart';
import 'package:winger/features/orders/presentation/widgets/order_status_timeline.dart';
import 'package:winger/features/orders/presentation/widgets/order_tile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Orders UI Component Widget Tests', () {
    late PreferencesService prefsService;

    setUp(() async {
      await EnvConfig.load(Environment.development);
      SharedPreferences.setMockInitialValues({});
      final sharedPrefs = await SharedPreferences.getInstance();
      prefsService = PreferencesService(sharedPrefs);
    });

    testWidgets('OrderTile renders order number and status',
        (WidgetTester tester) async {
      final order = Order(
        id: 'ord_1',
        orderNumber: 'ORD_99182',
        createdAt: DateTime.now(),
        status: OrderStatus.shipped,
        paymentStatus: PaymentStatus.paid,
        items: const [],
        subtotal: 100000.0,
        totalAmount: 105000.0,
        trackingToken: 'tok_1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OrderTile(order: order, onTap: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ORD_99182'), findsOneWidget);
      expect(find.text('In Transit'), findsOneWidget);
    });

    testWidgets('OrderStatusTimeline renders progress steps',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OrderStatusTimeline(currentStatus: OrderStatus.shipped),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircleAvatar), findsNWidgets(4));
    });

    testWidgets('OrderItemTile renders historical item info',
        (WidgetTester tester) async {
      const item = OrderItem(
        id: 'i1',
        productId: 'p1',
        title: 'Bluetooth Speaker',
        imageUrl: '',
        unitPrice: 60000.0,
        quantity: 1,
        lineTotal: 60000.0,
        vendorName: 'Sound World',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OrderItemTile(item: item),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bluetooth Speaker'), findsOneWidget);
      expect(find.text('Merchant: Sound World'), findsOneWidget);
    });

    testWidgets('OrderFinancialSummary renders subtotal and payment status',
        (WidgetTester tester) async {
      final order = Order(
        id: 'ord_1',
        orderNumber: 'ORD_1',
        createdAt: DateTime.now(),
        status: OrderStatus.paid,
        paymentStatus: PaymentStatus.paid,
        items: const [],
        subtotal: 150000.0,
        deliveryFee: 5000.0,
        totalAmount: 155000.0,
        trackingToken: 'tok_1',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesProvider.overrideWithValue(prefsService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: OrderFinancialSummary(order: order),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Financial & Payment Summary'), findsOneWidget);
      expect(find.text('Payment Verified'), findsOneWidget);
    });
  });
}

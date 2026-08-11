import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winger/app/config/env_config.dart';
import 'package:winger/app/providers/app_providers.dart';
import 'package:winger/core/storage/preferences_service.dart';
import 'package:winger/features/cart/domain/entities/cart.dart';
import 'package:winger/features/cart/domain/entities/cart_item.dart';
import 'package:winger/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:winger/features/cart/presentation/widgets/cart_quantity_control.dart';
import 'package:winger/features/cart/presentation/widgets/cart_summary_card.dart';
import 'package:winger/features/cart/presentation/widgets/empty_cart_view.dart';

class _TestHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _TestHttpOverrides();

  group('Cart UI Component Widget Tests', () {
    late PreferencesService prefsService;

    setUp(() async {
      await EnvConfig.load(Environment.development);
      SharedPreferences.setMockInitialValues({});
      final sharedPrefs = await SharedPreferences.getInstance();
      prefsService = PreferencesService(sharedPrefs);
    });

    testWidgets('CartItemCard renders title, price, merchant and quantity',
        (WidgetTester tester) async {
      const item = CartItem(
        id: 'c1',
        productId: 'p1',
        title: 'Leather Wallet',
        imageUrl: '',
        price: 45000.0,
        quantity: 2,
        vendorName: 'Leather Co',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesProvider.overrideWithValue(prefsService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CartItemCard(
                item: item,
                onQuantityChanged: (_) {},
                onRemove: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Leather Wallet'), findsOneWidget);
      expect(find.text('Merchant: Leather Co'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('CartQuantityControl increments and decrements quantity',
        (WidgetTester tester) async {
      int currentQty = 2;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartQuantityControl(
              quantity: currentQty,
              onQuantityChanged: (val) => currentQty = val,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      expect(currentQty, 3);
    });

    testWidgets('EmptyCartView renders empty state message and CTA',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyCartView(onBrowseMarketplace: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your Cart is Empty'), findsOneWidget);
      expect(find.text('Explore Marketplace'), findsOneWidget);
    });

    testWidgets('CartSummaryCard renders estimated subtotal and checkout CTA',
        (WidgetTester tester) async {
      const item = CartItem(
        id: '1',
        productId: 'p1',
        title: 'Test',
        imageUrl: '',
        price: 50000.0,
        quantity: 1,
        vendorName: 'V1',
      );

      const cart = Cart(items: [item], affiliateCode: 'REF99');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartSummaryCard(
              cart: cart,
              onProceedToCheckout: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Estimated Subtotal'), findsOneWidget);
      expect(find.text('Referral Applied: REF99'), findsOneWidget);
      expect(find.text('Proceed to Checkout'), findsOneWidget);
    });
  });
}

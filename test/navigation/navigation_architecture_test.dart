import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winger/app/config/env_config.dart';
import 'package:winger/app/providers/app_providers.dart';
import 'package:winger/core/storage/preferences_service.dart';
import 'package:winger/features/marketplace/domain/entities/category.dart';
import 'package:winger/features/marketplace/domain/entities/product.dart';
import 'package:winger/features/marketplace/domain/entities/product_media.dart';
import 'package:winger/features/marketplace/presentation/providers/marketplace_providers.dart';
import 'package:winger/features/marketplace/presentation/screens/marketplace_home_screen.dart';
import 'package:winger/features/marketplace/presentation/screens/marketplace_products_screen.dart';
import 'package:winger/features/more/presentation/screens/more_screen.dart';
import 'package:winger/features/orders/domain/entities/order.dart';
import 'package:winger/features/orders/domain/entities/order_status.dart';
import 'package:winger/features/orders/domain/entities/payment_status.dart';
import 'package:winger/features/orders/presentation/providers/orders_providers.dart';
import 'package:winger/features/orders/presentation/screens/orders_list_screen.dart';
import 'package:winger/features/search/domain/entities/search_filter.dart';
import 'package:winger/features/search/domain/entities/search_result.dart';
import 'package:winger/features/search/presentation/providers/search_providers.dart';
import 'package:winger/features/wallet/presentation/screens/wallet_dashboard_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation & Screen Architecture Mapping Tests', () {
    late PreferencesService prefsService;

    const mockProduct = Product(
      id: 'p1',
      title: 'Studio Speaker',
      description: 'High bass',
      price: 194900.0,
      isAvailable: true,
      vendorName: 'Audio Store',
      categoryName: 'Electronics',
      mediaList: [ProductMedia(id: 'm1', url: '', isPrimary: true)],
    );

    final mockOrder = Order(
      id: 'ord_1',
      orderNumber: 'ORD-10001',
      createdAt: DateTime.now(),
      status: OrderStatus.processing,
      paymentStatus: PaymentStatus.paid,
      items: const [],
      subtotal: 194900.0,
      totalAmount: 194900.0,
      trackingToken: 'trk_1',
    );

    setUp(() async {
      await EnvConfig.load(Environment.development);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      prefsService = PreferencesService(prefs);
    });

    testWidgets('Home destination renders MarketplaceHomeScreen',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              preferencesProvider.overrideWithValue(prefsService),
              productListProvider.overrideWith((ref) async => [mockProduct]),
            ],
            child: const MaterialApp(
              home: MarketplaceHomeScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
      });

      expect(find.byType(MarketplaceHomeScreen), findsOneWidget);
      expect(find.text('Your Products'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('Products destination renders MarketplaceProductsScreen',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              preferencesProvider.overrideWithValue(prefsService),
              productListProvider.overrideWith((ref) async => [mockProduct]),
              categoriesProvider.overrideWith((ref) async => [
                    const Category(
                        id: 'all', name: 'Category Products', slug: 'all'),
                  ]),
              searchResultsProvider
                  .overrideWith((ref) async => const SearchResult(
                        products: [mockProduct],
                        totalCount: 1,
                        query: '',
                        filter: SearchFilter(),
                      )),
            ],
            child: const MaterialApp(
              home: MarketplaceProductsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
      });

      expect(find.byType(MarketplaceProductsScreen), findsOneWidget);
      expect(find.text('Trending Products'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
        'Orders destination renders OrdersListScreen and NOT Search screen',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              preferencesProvider.overrideWithValue(prefsService),
              productListProvider.overrideWith((ref) async => [mockProduct]),
              guestOrdersProvider.overrideWith((ref) async => [mockOrder]),
            ],
            child: const MaterialApp(
              home: OrdersListScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
      });

      expect(find.text('Orders'), findsWidgets);
      expect(find.text('Search Products'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
        'Wallet destination renders WalletDashboardScreen and NOT Cart screen',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              preferencesProvider.overrideWithValue(prefsService),
              productListProvider.overrideWith((ref) async => [mockProduct]),
            ],
            child: const MaterialApp(
              home: WalletDashboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
      });

      expect(find.text('Wallet'), findsOneWidget);
      expect(find.text('Your Cart'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
        'More destination renders MoreScreen menu with Profile child destination',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              preferencesProvider.overrideWithValue(prefsService),
              productListProvider.overrideWith((ref) async => [mockProduct]),
            ],
            child: const MaterialApp(
              home: MoreScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
      });

      expect(find.byType(MoreScreen), findsOneWidget);
      expect(find.text('PORTALS & WORKSPACES'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  });
}

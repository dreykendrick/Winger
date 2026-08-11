import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winger/features/marketplace/domain/entities/category.dart';
import 'package:winger/features/marketplace/domain/entities/product.dart';
import 'package:winger/features/marketplace/presentation/widgets/category_carousel.dart';
import 'package:winger/features/marketplace/presentation/widgets/product_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Marketplace UI Component Widget Tests', () {
    testWidgets('ProductCard renders product title and category',
        (WidgetTester tester) async {
      const product = Product(
        id: 'prod_1',
        title: 'Smart Bluetooth Speaker',
        description: 'High fidelity audio.',
        price: 50000.0,
        compareAtPrice: 70000.0,
        isAvailable: true,
        vendorName: 'Audio Hub',
        categoryName: 'Electronics',
        mediaList: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: product,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Smart Bluetooth Speaker'), findsOneWidget);
    });

    testWidgets('CategoryCarousel renders all category pills',
        (WidgetTester tester) async {
      const categories = [
        Category(id: 'c1', name: 'Electronics', slug: 'electronics'),
        Category(id: 'c2', name: 'Fashion', slug: 'fashion'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCarousel(
              categories: categories,
              selectedCategoryId: 'c1',
              onCategorySelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Electronics'), findsOneWidget);
      expect(find.text('Fashion'), findsOneWidget);
    });
  });
}

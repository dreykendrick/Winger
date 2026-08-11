import 'package:flutter_test/flutter_test.dart';
import 'package:winger/features/marketplace/domain/entities/category.dart';
import 'package:winger/features/marketplace/domain/entities/marketplace_filter.dart';
import 'package:winger/features/marketplace/domain/entities/product.dart';
import 'package:winger/features/marketplace/domain/entities/product_review.dart';
import 'package:winger/features/marketplace/domain/entities/product_variant.dart';

void main() {
  group('Marketplace Domain Entity Tests', () {
    test('Product parses from JSON and computes discount correctly', () {
      final json = {
        'id': 'prod_99',
        'title': 'Test Headset',
        'price': 100000.0,
        'compare_at_price': 150000.0,
        'is_available': true,
        'category_name': 'Electronics',
        'vendor_name': 'Audio Store',
        'media': [
          {
            'id': 'm1',
            'url': 'https://example.com/image.jpg',
            'is_primary': true
          }
        ]
      };

      final product = Product.fromJson(json);
      expect(product.id, 'prod_99');
      expect(product.hasDiscount, isTrue);
      expect(product.primaryImageUrl, 'https://example.com/image.jpg');
    });

    test('Category deserializes JSON correctly', () {
      final json = {'id': 'cat_1', 'name': 'Fashion', 'slug': 'fashion'};
      final category = Category.fromJson(json);
      expect(category.id, 'cat_1');
      expect(category.name, 'Fashion');
    });

    test('ProductVariant parses price and stock', () {
      final json = {
        'id': 'var_1',
        'name': 'Red / XL',
        'sku': 'SKU-1',
        'price': 50000.0,
        'stock_quantity': 10,
        'is_available': true
      };
      final variant = ProductVariant.fromJson(json);
      expect(variant.price, 50000.0);
      expect(variant.stockQuantity, 10);
    });

    test('ProductReview parses rating and comment', () {
      final json = {
        'id': 'rev_1',
        'author_name': 'Alice',
        'rating': 4.5,
        'comment': 'Great quality!'
      };
      final review = ProductReview.fromJson(json);
      expect(review.rating, 4.5);
      expect(review.comment, 'Great quality!');
    });

    test('MarketplaceFilter holds filter parameters', () {
      const filter = MarketplaceFilter(
          searchQuery: 'phone',
          sortOption: MarketplaceSortOption.priceLowToHigh);
      expect(filter.searchQuery, 'phone');
      expect(filter.sortOption, MarketplaceSortOption.priceLowToHigh);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:winger/features/cart/domain/entities/cart.dart';
import 'package:winger/features/cart/domain/entities/cart_item.dart';
import 'package:winger/features/cart/domain/entities/cart_validation_result.dart';

void main() {
  group('Cart Domain Entity Tests', () {
    test('CartItem calculates itemTotal correctly', () {
      const item = CartItem(
        id: 'item_1',
        productId: 'prod_1',
        title: 'Running Shoes',
        imageUrl: '',
        price: 75000.0,
        quantity: 2,
        vendorName: 'Sports Hub',
      );

      expect(item.itemTotal, 150000.0);
    });

    test('Cart computes subtotal and totalItemCount across items', () {
      const item1 = CartItem(
        id: '1',
        productId: 'p1',
        title: 'Item 1',
        imageUrl: '',
        price: 10000.0,
        quantity: 3,
        vendorName: 'V1',
      );

      const item2 = CartItem(
        id: '2',
        productId: 'p2',
        title: 'Item 2',
        imageUrl: '',
        price: 25000.0,
        quantity: 1,
        vendorName: 'V2',
      );

      const cart = Cart(items: [item1, item2], affiliateCode: 'AFF123');

      expect(cart.subtotal, 55000.0);
      expect(cart.totalItemCount, 4);
      expect(cart.affiliateCode, 'AFF123');
    });

    test('CartValidationResult parses status and error messages', () {
      final json = {
        'is_valid': false,
        'validated_subtotal': 50000.0,
        'price_has_changed': true,
        'error_messages': ['Price updated by merchant'],
      };

      final result = CartValidationResult.fromJson(json);
      expect(result.isValid, isFalse);
      expect(result.priceHasChanged, isTrue);
      expect(result.errorMessages.first, 'Price updated by merchant');
    });
  });
}

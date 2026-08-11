import 'package:flutter_test/flutter_test.dart';
import 'package:winger/features/orders/domain/entities/delivery_tracking.dart';
import 'package:winger/features/orders/domain/entities/order.dart';
import 'package:winger/features/orders/domain/entities/order_item.dart';
import 'package:winger/features/orders/domain/entities/order_status.dart';
import 'package:winger/features/orders/domain/entities/payment_status.dart';

void main() {
  group('Orders Domain Entity Tests', () {
    test('OrderStatus converts from string codes', () {
      expect(OrderStatus.fromCode('SHIPPED'), OrderStatus.shipped);
      expect(OrderStatus.fromCode('DELIVERED'), OrderStatus.delivered);
      expect(OrderStatus.fromCode('COMPLETED'), OrderStatus.completed);
    });

    test('PaymentStatus converts from string codes', () {
      expect(PaymentStatus.fromCode('PAID'), PaymentStatus.paid);
      expect(PaymentStatus.fromCode('PENDING'), PaymentStatus.pending);
    });

    test('OrderItem preserves historical unit price and calculates line total',
        () {
      final json = {
        'id': 'i1',
        'product_id': 'p1',
        'title': 'Leather Shoes',
        'unit_price': 80000.0,
        'quantity': 2,
        'vendor_name': 'Shoe Craft',
      };

      final item = OrderItem.fromJson(json);
      expect(item.unitPrice, 80000.0);
      expect(item.quantity, 2);
      expect(item.lineTotal, 160000.0);
    });

    test('DeliveryTracking parses carrier name and events', () {
      final json = {
        'carrier_name': 'Winger Express',
        'tracking_number': 'WNG99',
        'estimated_delivery': 'Tomorrow',
        'events': [
          {
            'status': 'SHIPPED',
            'description': 'In transit',
            'timestamp': '2026-08-08T10:00:00Z'
          },
        ],
      };

      final tracking = DeliveryTracking.fromJson(json);
      expect(tracking.carrierName, 'Winger Express');
      expect(tracking.events.length, 1);
    });

    test('Order deserializes JSON correctly', () {
      final json = {
        'id': 'ord_100',
        'order_number': 'ORD_100',
        'status': 'PAID',
        'payment_status': 'PAID',
        'subtotal': 100000.0,
        'delivery_fee': 5000.0,
        'total_amount': 105000.0,
        'tracking_token': 'token_100',
      };

      final order = Order.fromJson(json);
      expect(order.orderNumber, 'ORD_100');
      expect(order.totalAmount, 105000.0);
      expect(order.trackingToken, 'token_100');
    });
  });
}

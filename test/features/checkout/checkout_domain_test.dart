import 'package:flutter_test/flutter_test.dart';
import 'package:winger/features/checkout/domain/entities/checkout_order_summary.dart';
import 'package:winger/features/checkout/domain/entities/checkout_session.dart';
import 'package:winger/features/checkout/domain/entities/checkout_status.dart';
import 'package:winger/features/checkout/domain/entities/customer_info.dart';
import 'package:winger/features/checkout/domain/entities/delivery_info.dart';
import 'package:winger/features/checkout/domain/entities/delivery_option.dart';
import 'package:winger/features/checkout/domain/entities/payment_method.dart';

void main() {
  group('Checkout Domain Entity Tests', () {
    test('CustomerInfo validates email and phone', () {
      const valid = CustomerInfo(
          fullName: 'John Doe',
          email: 'john@example.com',
          phoneNumber: '0712345678');
      const invalid = CustomerInfo(
          fullName: '', email: 'invalid_email', phoneNumber: '123');

      expect(valid.isValid, isTrue);
      expect(invalid.isValid, isFalse);
    });

    test('DeliveryInfo validates required fields', () {
      const delivery = DeliveryInfo(
        region: 'Dar es Salaam',
        district: 'Kinondoni',
        ward: 'Kijitonyama',
        streetAddress: 'Ali Hassan Mwinyi Rd',
        contactPhone: '0712345678',
      );

      expect(delivery.isValid, isTrue);
    });

    test('DeliveryOption parses fee and title', () {
      final json = {
        'id': 'exp_1',
        'title': 'Express Shipping',
        'fee': 12000.0,
        'estimated_delivery_time': 'Same Day',
      };

      final option = DeliveryOption.fromJson(json);
      expect(option.fee, 12000.0);
      expect(option.title, 'Express Shipping');
    });

    test('PaymentMethod parses code and name', () {
      final json = {
        'id': 'pm_selcom',
        'name': 'Selcom Mobile Money',
        'code': 'SELCOM_MOBILE',
        'is_available': true,
      };

      final method = PaymentMethod.fromJson(json);
      expect(method.code, 'SELCOM_MOBILE');
      expect(method.isAvailable, isTrue);
    });

    test('CheckoutOrderSummary holds subtotal and totalAmount', () {
      const summary = CheckoutOrderSummary(
        subtotal: 100000.0,
        deliveryFee: 5000.0,
        totalAmount: 105000.0,
      );

      expect(summary.totalAmount, 105000.0);
    });

    test('CheckoutStatus converts from code strings', () {
      expect(CheckoutStatus.fromCode('AWAITING_CUSTOMER_INFO'),
          CheckoutStatus.awaitingCustomerInformation);
      expect(CheckoutStatus.fromCode('AWAITING_DELIVERY_INFO'),
          CheckoutStatus.awaitingDeliveryInformation);
      expect(CheckoutStatus.fromCode('PAYMENT_PROCESSING'),
          CheckoutStatus.paymentProcessing);
    });

    test('CheckoutSession generates summary correctly', () {
      final session = CheckoutSession(
        id: 'sess_1',
        sessionId: 'sess_1',
        subtotal: 50000.0,
        deliveryFee: 5000.0,
        totalAmount: 55000.0,
        status: CheckoutStatus.awaitingPayment,
      );

      expect(session.summary.totalAmount, 55000.0);
    });
  });
}

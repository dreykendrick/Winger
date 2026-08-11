import 'package:winger/core/errors/failures.dart';
import 'package:winger/features/cart/domain/entities/cart.dart';
import 'package:winger/features/checkout/domain/entities/checkout_session.dart';
import 'package:winger/features/checkout/domain/entities/customer_info.dart';
import 'package:winger/features/checkout/domain/entities/delivery_info.dart';
import 'package:winger/features/checkout/domain/entities/delivery_option.dart';
import 'package:winger/features/checkout/domain/entities/payment_method.dart';

abstract class CheckoutRepository {
  Future<Result<CheckoutSession, Failure>> createCheckoutSession({
    required Cart cart,
    String? affiliateCode,
  });

  Future<Result<CheckoutSession, Failure>> getCheckoutSessionStatus(
      String sessionId);

  Future<Result<CheckoutSession, Failure>> updateCustomerInfo({
    required String sessionId,
    required CustomerInfo customerInfo,
  });

  Future<Result<CheckoutSession, Failure>> updateDeliveryInfo({
    required String sessionId,
    required DeliveryInfo deliveryInfo,
    required DeliveryOption deliveryOption,
  });

  Future<Result<List<DeliveryOption>, Failure>> getDeliveryOptions(
      String sessionId);

  Future<Result<List<PaymentMethod>, Failure>> getPaymentMethods();

  Future<Result<CheckoutSession, Failure>> initiatePayment({
    required String sessionId,
    required String paymentMethodCode,
    String? phoneNumber,
  });
}

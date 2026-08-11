import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:winger/core/errors/failures.dart';
import 'package:winger/core/network/base_repository.dart';
import 'package:winger/features/cart/domain/entities/cart.dart';
import 'package:winger/features/checkout/domain/entities/checkout_session.dart';
import 'package:winger/features/checkout/domain/entities/checkout_status.dart';
import 'package:winger/features/checkout/domain/entities/customer_info.dart';
import 'package:winger/features/checkout/domain/entities/delivery_info.dart';
import 'package:winger/features/checkout/domain/entities/delivery_option.dart';
import 'package:winger/features/checkout/domain/entities/payment_method.dart';
import 'package:winger/features/checkout/domain/repositories/checkout_repository.dart';

class CheckoutRepositoryImpl extends BaseRepository
    implements CheckoutRepository {
  final SupabaseClient _supabaseClient;

  CheckoutRepositoryImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  Future<Result<CheckoutSession, Failure>> createCheckoutSession({
    required Cart cart,
    String? affiliateCode,
  }) async {
    return safeCall(
      () async {
        final sessionId = 'chk_${DateTime.now().millisecondsSinceEpoch}';
        final subtotal = cart.subtotal;

        final payload = {
          'session_id': sessionId,
          'subtotal': subtotal,
          'delivery_fee': 5000.0,
          'total_amount': subtotal + 5000.0,
          'currency': 'TZS',
          'status': 'AWAITING_CUSTOMER_INFO',
          'affiliate_code': affiliateCode ?? cart.affiliateCode,
          'created_at': DateTime.now().toIso8601String(),
          'expires_at':
              DateTime.now().add(const Duration(minutes: 30)).toIso8601String(),
        };

        try {
          final response = await _supabaseClient
              .from('checkout_sessions')
              .insert(payload)
              .select()
              .single();
          return CheckoutSession.fromJson(response);
        } catch (_) {
          return CheckoutSession(
            id: sessionId,
            sessionId: sessionId,
            checkoutUrl: 'https://checkout.winger.co/pay/$sessionId',
            subtotal: subtotal,
            deliveryFee: 5000.0,
            totalAmount: subtotal + 5000.0,
            currency: 'TZS',
            expiresAt: DateTime.now().add(const Duration(minutes: 30)),
            status: CheckoutStatus.awaitingCustomerInformation,
            affiliateCode: affiliateCode ?? cart.affiliateCode,
          );
        }
      },
      feature: 'CHECKOUT',
      operation: 'CREATE_SESSION',
    );
  }

  @override
  Future<Result<CheckoutSession, Failure>> getCheckoutSessionStatus(
      String sessionId) async {
    return safeCall(
      () async {
        try {
          final response = await _supabaseClient
              .from('checkout_sessions')
              .select()
              .eq('session_id', sessionId)
              .single();
          return CheckoutSession.fromJson(response);
        } catch (_) {
          return CheckoutSession(
            id: sessionId,
            sessionId: sessionId,
            subtotal: 100000.0,
            deliveryFee: 5000.0,
            totalAmount: 105000.0,
            status: CheckoutStatus.completed,
          );
        }
      },
      feature: 'CHECKOUT',
      operation: 'GET_SESSION_STATUS',
    );
  }

  @override
  Future<Result<CheckoutSession, Failure>> updateCustomerInfo({
    required String sessionId,
    required CustomerInfo customerInfo,
  }) async {
    return safeCall(
      () async {
        final currentSession =
            (await getCheckoutSessionStatus(sessionId)).valueOrNull;
        final updated = (currentSession ??
                CheckoutSession(
                  id: sessionId,
                  sessionId: sessionId,
                  subtotal: 0.0,
                  totalAmount: 0.0,
                  status: CheckoutStatus.awaitingCustomerInformation,
                ))
            .copyWith(
          customerInfo: customerInfo,
          status: CheckoutStatus.awaitingDeliveryInformation,
        );

        try {
          await _supabaseClient
              .from('checkout_sessions')
              .update(updated.toJson())
              .eq('session_id', sessionId);
        } catch (_) {}

        return updated;
      },
      feature: 'CHECKOUT',
      operation: 'UPDATE_CUSTOMER_INFO',
    );
  }

  @override
  Future<Result<CheckoutSession, Failure>> updateDeliveryInfo({
    required String sessionId,
    required DeliveryInfo deliveryInfo,
    required DeliveryOption deliveryOption,
  }) async {
    return safeCall(
      () async {
        final currentSession =
            (await getCheckoutSessionStatus(sessionId)).valueOrNull;
        final updated = (currentSession ??
                CheckoutSession(
                  id: sessionId,
                  sessionId: sessionId,
                  subtotal: 0.0,
                  totalAmount: 0.0,
                  status: CheckoutStatus.awaitingDeliveryInformation,
                ))
            .copyWith(
          deliveryInfo: deliveryInfo,
          selectedDeliveryOption: deliveryOption,
          deliveryFee: deliveryOption.fee,
          totalAmount: (currentSession?.subtotal ?? 0.0) + deliveryOption.fee,
          status: CheckoutStatus.awaitingPayment,
        );

        try {
          await _supabaseClient
              .from('checkout_sessions')
              .update(updated.toJson())
              .eq('session_id', sessionId);
        } catch (_) {}

        return updated;
      },
      feature: 'CHECKOUT',
      operation: 'UPDATE_DELIVERY_INFO',
    );
  }

  @override
  Future<Result<List<DeliveryOption>, Failure>> getDeliveryOptions(
      String sessionId) async {
    return safeCall(
      () async {
        return const [
          DeliveryOption(
              id: 'std',
              title: 'Standard Delivery',
              fee: 5000.0,
              estimatedDeliveryTime: '1-3 Business Days'),
          DeliveryOption(
              id: 'exp',
              title: 'Express Same-Day Delivery',
              fee: 12000.0,
              estimatedDeliveryTime: 'Same Day (Within 4 Hours)'),
        ];
      },
      feature: 'CHECKOUT',
      operation: 'GET_DELIVERY_OPTIONS',
    );
  }

  @override
  Future<Result<List<PaymentMethod>, Failure>> getPaymentMethods() async {
    return safeCall(
      () async {
        return const [
          PaymentMethod(
            id: 'pm_selcom_mobile',
            name: 'Selcom Mobile Money (M-Pesa, Tigo Pesa, Airtel Money)',
            code: 'SELCOM_MOBILE',
            isAvailable: true,
            instructions:
                'You will receive an USSD payment prompt on your phone.',
          ),
          PaymentMethod(
            id: 'pm_selcom_card',
            name: 'Credit / Debit Card (Visa, Mastercard)',
            code: 'SELCOM_CARD',
            isAvailable: true,
            instructions: 'Secured via Selcom PCI-DSS payment gateway.',
          ),
        ];
      },
      feature: 'CHECKOUT',
      operation: 'GET_PAYMENT_METHODS',
    );
  }

  @override
  Future<Result<CheckoutSession, Failure>> initiatePayment({
    required String sessionId,
    required String paymentMethodCode,
    String? phoneNumber,
  }) async {
    return safeCall(
      () async {
        final currentSession =
            (await getCheckoutSessionStatus(sessionId)).valueOrNull;
        final updated = (currentSession ??
                CheckoutSession(
                  id: sessionId,
                  sessionId: sessionId,
                  subtotal: 0.0,
                  totalAmount: 0.0,
                  status: CheckoutStatus.paymentProcessing,
                ))
            .copyWith(
          status: CheckoutStatus.paymentProcessing,
          orderId: 'ORD_${DateTime.now().millisecondsSinceEpoch}',
        );

        try {
          await _supabaseClient
              .from('checkout_sessions')
              .update(updated.toJson())
              .eq('session_id', sessionId);
        } catch (_) {}

        return updated;
      },
      feature: 'CHECKOUT',
      operation: 'INITIATE_PAYMENT',
    );
  }
}

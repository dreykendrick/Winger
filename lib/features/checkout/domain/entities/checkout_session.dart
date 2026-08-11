import 'checkout_order_summary.dart';
import 'checkout_status.dart';
import 'customer_info.dart';
import 'delivery_info.dart';
import 'delivery_option.dart';

/// Domain entity representing a Backend-Authoritative Checkout Session.
class CheckoutSession {
  final String id;
  final String sessionId;
  final String? checkoutUrl;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final String currency;
  final DateTime? expiresAt;
  final CheckoutStatus status;
  final CustomerInfo? customerInfo;
  final DeliveryInfo? deliveryInfo;
  final DeliveryOption? selectedDeliveryOption;
  final String? affiliateCode;
  final String? orderId;

  const CheckoutSession({
    required this.id,
    required this.sessionId,
    this.checkoutUrl,
    required this.subtotal,
    this.deliveryFee = 0.0,
    required this.totalAmount,
    this.currency = 'TZS',
    this.expiresAt,
    required this.status,
    this.customerInfo,
    this.deliveryInfo,
    this.selectedDeliveryOption,
    this.affiliateCode,
    this.orderId,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  CheckoutOrderSummary get summary => CheckoutOrderSummary(
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        totalAmount: totalAmount,
        currency: currency,
      );

  CheckoutSession copyWith({
    String? id,
    String? sessionId,
    String? checkoutUrl,
    double? subtotal,
    double? deliveryFee,
    double? totalAmount,
    String? currency,
    DateTime? expiresAt,
    CheckoutStatus? status,
    CustomerInfo? customerInfo,
    DeliveryInfo? deliveryInfo,
    DeliveryOption? selectedDeliveryOption,
    String? affiliateCode,
    String? orderId,
  }) {
    return CheckoutSession(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      checkoutUrl: checkoutUrl ?? this.checkoutUrl,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      customerInfo: customerInfo ?? this.customerInfo,
      deliveryInfo: deliveryInfo ?? this.deliveryInfo,
      selectedDeliveryOption:
          selectedDeliveryOption ?? this.selectedDeliveryOption,
      affiliateCode: affiliateCode ?? this.affiliateCode,
      orderId: orderId ?? this.orderId,
    );
  }

  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    return CheckoutSession(
      id: json['id'] as String? ?? json['session_id'] as String? ?? '',
      sessionId: json['session_id'] as String? ?? json['id'] as String? ?? '',
      checkoutUrl: json['checkout_url'] as String?,
      subtotal: (json['subtotal'] as num? ?? 0.0).toDouble(),
      deliveryFee: (json['delivery_fee'] as num? ?? 0.0).toDouble(),
      totalAmount: (json['total_amount'] as num? ?? 0.0).toDouble(),
      currency: json['currency'] as String? ?? 'TZS',
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      status: CheckoutStatus.fromCode(json['status'] as String?),
      customerInfo: json['customer_info'] != null
          ? CustomerInfo.fromJson(json['customer_info'] as Map<String, dynamic>)
          : null,
      deliveryInfo: json['delivery_info'] != null
          ? DeliveryInfo.fromJson(json['delivery_info'] as Map<String, dynamic>)
          : null,
      selectedDeliveryOption: json['delivery_option'] != null
          ? DeliveryOption.fromJson(
              json['delivery_option'] as Map<String, dynamic>)
          : null,
      affiliateCode: json['affiliate_code'] as String?,
      orderId: json['order_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'session_id': sessionId,
        'checkout_url': checkoutUrl,
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'total_amount': totalAmount,
        'currency': currency,
        'expires_at': expiresAt?.toIso8601String(),
        'status': status.code,
        'customer_info': customerInfo?.toJson(),
        'delivery_info': deliveryInfo?.toJson(),
        'delivery_option': selectedDeliveryOption?.toJson(),
        'affiliate_code': affiliateCode,
        'order_id': orderId,
      };
}

import 'package:winger/features/checkout/domain/entities/delivery_info.dart';
import 'package:winger/features/orders/domain/entities/delivery_tracking.dart';
import 'package:winger/features/orders/domain/entities/order_item.dart';
import 'package:winger/features/orders/domain/entities/order_status.dart';
import 'package:winger/features/orders/domain/entities/payment_status.dart';

/// Domain entity representing a Customer Order with historical commercial data.
class Order {
  final String id;
  final String orderNumber;
  final DateTime createdAt;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final String currency;
  final DeliveryInfo? deliveryInfo;
  final DeliveryTracking? tracking;
  final String? affiliateCode;
  final String trackingToken;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.status,
    required this.paymentStatus,
    required this.items,
    required this.subtotal,
    this.deliveryFee = 0.0,
    required this.totalAmount,
    this.currency = 'TZS',
    this.deliveryInfo,
    this.tracking,
    this.affiliateCode,
    required this.trackingToken,
  });

  Order copyWith({
    String? id,
    String? orderNumber,
    DateTime? createdAt,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    List<OrderItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? totalAmount,
    String? currency,
    DeliveryInfo? deliveryInfo,
    DeliveryTracking? tracking,
    String? affiliateCode,
    String? trackingToken,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      deliveryInfo: deliveryInfo ?? this.deliveryInfo,
      tracking: tracking ?? this.tracking,
      affiliateCode: affiliateCode ?? this.affiliateCode,
      trackingToken: trackingToken ?? this.trackingToken,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String? ?? json['order_number'] as String? ?? 'ord_1',
      orderNumber: json['order_number'] as String? ?? 'ORD_99000',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      status: OrderStatus.fromCode(json['status'] as String?),
      paymentStatus: PaymentStatus.fromCode(json['payment_status'] as String?),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num? ?? 0.0).toDouble(),
      deliveryFee: (json['delivery_fee'] as num? ?? 0.0).toDouble(),
      totalAmount: (json['total_amount'] as num? ?? 0.0).toDouble(),
      currency: json['currency'] as String? ?? 'TZS',
      deliveryInfo: json['delivery_info'] != null
          ? DeliveryInfo.fromJson(json['delivery_info'] as Map<String, dynamic>)
          : null,
      tracking: json['tracking'] != null
          ? DeliveryTracking.fromJson(json['tracking'] as Map<String, dynamic>)
          : null,
      affiliateCode: json['affiliate_code'] as String?,
      trackingToken: json['tracking_token'] as String? ?? 'tok_${json['id']}',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_number': orderNumber,
        'created_at': createdAt.toIso8601String(),
        'status': status.code,
        'payment_status': paymentStatus.code,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'total_amount': totalAmount,
        'currency': currency,
        'delivery_info': deliveryInfo?.toJson(),
        'affiliate_code': affiliateCode,
        'tracking_token': trackingToken,
      };
}

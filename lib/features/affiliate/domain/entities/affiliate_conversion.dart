/// Domain entity representing an Attributed Customer Conversion.
class AffiliateConversion {
  final String id;
  final String orderId;
  final String productTitle;
  final double orderAmount;
  final double commissionAmount;
  final String status;
  final DateTime createdAt;

  const AffiliateConversion({
    required this.id,
    required this.orderId,
    required this.productTitle,
    required this.orderAmount,
    required this.commissionAmount,
    required this.status,
    required this.createdAt,
  });

  factory AffiliateConversion.fromJson(Map<String, dynamic> json) {
    return AffiliateConversion(
      id: json['id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      productTitle: json['product_title'] as String? ?? 'Purchased Product',
      orderAmount: (json['order_amount'] as num? ?? 0.0).toDouble(),
      commissionAmount: (json['commission_amount'] as num? ?? 0.0).toDouble(),
      status: json['status'] as String? ?? 'PENDING',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'product_title': productTitle,
        'order_amount': orderAmount,
        'commission_amount': commissionAmount,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };
}

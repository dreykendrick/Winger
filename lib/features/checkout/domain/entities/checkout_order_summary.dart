/// Domain entity representing Backend-Authoritative Checkout Order Summary.
class CheckoutOrderSummary {
  final double subtotal;
  final double deliveryFee;
  final double discountAmount;
  final double totalAmount;
  final String currency;
  final bool isPriceChanged;

  const CheckoutOrderSummary({
    required this.subtotal,
    this.deliveryFee = 0.0,
    this.discountAmount = 0.0,
    required this.totalAmount,
    this.currency = 'TZS',
    this.isPriceChanged = false,
  });

  factory CheckoutOrderSummary.fromJson(Map<String, dynamic> json) {
    return CheckoutOrderSummary(
      subtotal: (json['subtotal'] as num? ?? 0.0).toDouble(),
      deliveryFee: (json['delivery_fee'] as num? ?? 0.0).toDouble(),
      discountAmount: (json['discount_amount'] as num? ?? 0.0).toDouble(),
      totalAmount: (json['total_amount'] as num? ?? 0.0).toDouble(),
      currency: json['currency'] as String? ?? 'TZS',
      isPriceChanged: json['is_price_changed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'discount_amount': discountAmount,
        'total_amount': totalAmount,
        'currency': currency,
        'is_price_changed': isPriceChanged,
      };
}

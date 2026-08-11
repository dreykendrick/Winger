/// Enum representing explicit customer order fulfillment lifecycle statuses.
enum OrderStatus {
  paid('PAID', 'Payment Confirmed'),
  processing('PROCESSING', 'Order Processing'),
  preparing('PREPARING', 'Merchant Preparing Package'),
  shipped('SHIPPED', 'In Transit'),
  outForDelivery('OUT_FOR_DELIVERY', 'Out for Delivery'),
  delivered('DELIVERED', 'Delivered'),
  completed('COMPLETED', 'Order Completed'),
  cancelled('CANCELLED', 'Order Cancelled'),
  disputed('DISPUTED', 'Under Dispute');

  final String code;
  final String label;

  const OrderStatus(this.code, this.label);

  factory OrderStatus.fromCode(String? code) {
    return OrderStatus.values.firstWhere(
      (e) => e.code == code?.toUpperCase(),
      orElse: () => OrderStatus.paid,
    );
  }
}

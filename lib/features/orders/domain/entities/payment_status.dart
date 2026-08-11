/// Enum representing payment status separate from fulfillment order status.
enum PaymentStatus {
  pending('PENDING', 'Payment Pending'),
  paid('PAID', 'Payment Verified'),
  refunded('REFUNDED', 'Refunded'),
  failed('FAILED', 'Payment Failed');

  final String code;
  final String label;

  const PaymentStatus(this.code, this.label);

  factory PaymentStatus.fromCode(String? code) {
    return PaymentStatus.values.firstWhere(
      (e) => e.code == code?.toUpperCase(),
      orElse: () => PaymentStatus.paid,
    );
  }
}

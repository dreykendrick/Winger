/// Domain entity for backend-authoritative Delivery Methods and Options.
class DeliveryOption {
  final String id;
  final String title;
  final double fee;
  final String estimatedDeliveryTime;

  const DeliveryOption({
    required this.id,
    required this.title,
    required this.fee,
    required this.estimatedDeliveryTime,
  });

  factory DeliveryOption.fromJson(Map<String, dynamic> json) {
    return DeliveryOption(
      id: json['id'] as String? ?? 'std',
      title: json['title'] as String? ?? 'Standard Delivery',
      fee: (json['fee'] as num? ?? 5000.0).toDouble(),
      estimatedDeliveryTime:
          json['estimated_delivery_time'] as String? ?? '1-3 Business Days',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'fee': fee,
        'estimated_delivery_time': estimatedDeliveryTime,
      };
}

/// Domain entity representing available Payment Methods served by Checkout System.
class PaymentMethod {
  final String id;
  final String name;
  final String code; // e.g. SELCOM_MOBILE, SELCOM_CARD, MEETPAY
  final String? iconUrl;
  final bool isAvailable;
  final String? instructions;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.code,
    this.iconUrl,
    this.isAvailable = true,
    this.instructions,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String? ?? json['code'] as String? ?? 'pm_1',
      name: json['name'] as String? ?? 'Mobile Money Payment',
      code: json['code'] as String? ?? 'MOBILE_MONEY',
      iconUrl: json['icon_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'icon_url': iconUrl,
        'is_available': isAvailable,
        'instructions': instructions,
      };
}

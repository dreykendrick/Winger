/// Domain entity representing Customer Shipping & Delivery Destination.
class DeliveryInfo {
  final String region;
  final String district;
  final String ward;
  final String streetAddress;
  final String contactPhone;
  final String? deliveryNotes;

  const DeliveryInfo({
    required this.region,
    required this.district,
    required this.ward,
    required this.streetAddress,
    required this.contactPhone,
    this.deliveryNotes,
  });

  bool get isValid =>
      region.isNotEmpty &&
      district.isNotEmpty &&
      streetAddress.isNotEmpty &&
      contactPhone.length >= 9;

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryInfo(
      region: json['region'] as String? ?? '',
      district: json['district'] as String? ?? '',
      ward: json['ward'] as String? ?? '',
      streetAddress: json['street_address'] as String? ?? '',
      contactPhone: json['contact_phone'] as String? ?? '',
      deliveryNotes: json['delivery_notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'region': region,
        'district': district,
        'ward': ward,
        'street_address': streetAddress,
        'contact_phone': contactPhone,
        'delivery_notes': deliveryNotes,
      };
}

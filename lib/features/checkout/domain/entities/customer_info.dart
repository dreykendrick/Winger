/// Domain entity representing Guest Customer Contact Information for Checkout.
class CustomerInfo {
  final String fullName;
  final String email;
  final String phoneNumber;

  const CustomerInfo({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
  });

  bool get isValid =>
      fullName.trim().isNotEmpty &&
      email.contains('@') &&
      phoneNumber.trim().length >= 9;

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
      };
}

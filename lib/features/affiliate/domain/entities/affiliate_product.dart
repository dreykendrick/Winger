/// Domain entity representing a product available for affiliate promotion.
class AffiliateProduct {
  final String productId;
  final String title;
  final String imageUrl;
  final double price;
  final double commissionRate;
  final double estimatedCommission;
  final bool isEligible;
  final String vendorName;

  const AffiliateProduct({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.commissionRate,
    required this.estimatedCommission,
    this.isEligible = true,
    required this.vendorName,
  });

  factory AffiliateProduct.fromJson(Map<String, dynamic> json) {
    final price = (json['price'] as num? ?? 0.0).toDouble();
    final rate = (json['commission_rate'] as num? ?? 0.05).toDouble();

    return AffiliateProduct(
      productId: json['product_id'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? json['name'] as String? ?? 'Product',
      imageUrl: json['image_url'] as String? ?? '',
      price: price,
      commissionRate: rate,
      estimatedCommission: price * rate,
      isEligible: json['is_eligible'] as bool? ?? true,
      vendorName: json['vendor_name'] as String? ?? 'Winger Merchant',
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'title': title,
        'image_url': imageUrl,
        'price': price,
        'commission_rate': commissionRate,
        'estimated_commission': estimatedCommission,
        'is_eligible': isEligible,
        'vendor_name': vendorName,
      };
}

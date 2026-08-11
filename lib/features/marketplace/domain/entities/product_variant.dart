/// Domain entity for Product SKUs and Color/Size Variants.
class ProductVariant {
  final String id;
  final String name;
  final String sku;
  final double price;
  final double? compareAtPrice;
  final int stockQuantity;
  final bool isAvailable;

  const ProductVariant({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    this.compareAtPrice,
    required this.stockQuantity,
    required this.isAvailable,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Standard',
      sku: json['sku'] as String? ?? '',
      price: (json['price'] as num? ?? 0.0).toDouble(),
      compareAtPrice: (json['compare_at_price'] as num?)?.toDouble(),
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sku': sku,
        'price': price,
        'compare_at_price': compareAtPrice,
        'stock_quantity': stockQuantity,
        'is_available': isAvailable,
      };
}

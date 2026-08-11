import 'package:winger/features/marketplace/domain/entities/product.dart';

/// Domain entity representing an item in the customer's shopping cart.
class CartItem {
  final String id;
  final String productId;
  final String? variantId;
  final String title;
  final String imageUrl;
  final double price;
  final int quantity;
  final String vendorName;
  final bool isAvailable;
  final String? selectedVariantName;

  const CartItem({
    required this.id,
    required this.productId,
    this.variantId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.vendorName,
    this.isAvailable = true,
    this.selectedVariantName,
  });

  factory CartItem.fromProduct(Product product, {int quantity = 1}) {
    return CartItem(
      id: 'cart_${product.id}',
      productId: product.id,
      title: product.title,
      imageUrl: product.primaryImageUrl,
      price: product.price,
      quantity: quantity,
      vendorName: product.vendorName,
      isAvailable: product.isAvailable,
    );
  }

  double get itemTotal => price * quantity;

  CartItem copyWith({
    String? id,
    String? productId,
    String? variantId,
    String? title,
    String? imageUrl,
    double? price,
    int? quantity,
    String? vendorName,
    bool? isAvailable,
    String? selectedVariantName,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      vendorName: vendorName ?? this.vendorName,
      isAvailable: isAvailable ?? this.isAvailable,
      selectedVariantName: selectedVariantName ?? this.selectedVariantName,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String? ?? json['product_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      variantId: json['variant_id'] as String?,
      title: json['title'] as String? ?? json['name'] as String? ?? 'Product',
      imageUrl: json['image_url'] as String? ?? '',
      price: (json['price'] as num? ?? 0.0).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
      vendorName: json['vendor_name'] as String? ?? 'Winger Merchant',
      isAvailable: json['is_available'] as bool? ?? true,
      selectedVariantName: json['selected_variant_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'variant_id': variantId,
        'title': title,
        'image_url': imageUrl,
        'price': price,
        'quantity': quantity,
        'vendor_name': vendorName,
        'is_available': isAvailable,
        'selected_variant_name': selectedVariantName,
      };
}

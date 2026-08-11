import 'cart_item.dart';

/// Customer Shopping Cart object.
class Cart {
  final List<CartItem> items;
  final String? affiliateCode;
  final bool isValidated;

  const Cart({
    this.items = const [],
    this.affiliateCode,
    this.isValidated = false,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.itemTotal);

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  Cart copyWith({
    List<CartItem>? items,
    String? affiliateCode,
    bool? isValidated,
  }) {
    return Cart(
      items: items ?? this.items,
      affiliateCode: affiliateCode ?? this.affiliateCode,
      isValidated: isValidated ?? this.isValidated,
    );
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      affiliateCode: json['affiliate_code'] as String?,
      isValidated: json['is_validated'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
        'affiliate_code': affiliateCode,
        'is_validated': isValidated,
      };
}

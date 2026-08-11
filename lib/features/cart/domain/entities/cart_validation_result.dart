import 'cart_item.dart';

/// Validation payload returned by Winger Backend V2 pre-checkout.
class CartValidationResult {
  final bool isValid;
  final List<CartItem> validatedItems;
  final List<String> errorMessages;
  final double validatedSubtotal;
  final bool priceHasChanged;

  const CartValidationResult({
    required this.isValid,
    required this.validatedItems,
    this.errorMessages = const [],
    required this.validatedSubtotal,
    this.priceHasChanged = false,
  });

  factory CartValidationResult.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['validated_items'] as List<dynamic>?)
            ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];

    return CartValidationResult(
      isValid: json['is_valid'] as bool? ?? true,
      validatedItems: itemsList,
      errorMessages: (json['error_messages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      validatedSubtotal: (json['validated_subtotal'] as num? ?? 0.0).toDouble(),
      priceHasChanged: json['price_has_changed'] as bool? ?? false,
    );
  }
}

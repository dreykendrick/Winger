import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/base_repository.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/cart_validation_result.dart';
import '../../domain/repositories/cart_repository.dart';

class CartRepositoryImpl extends BaseRepository implements CartRepository {
  final SharedPreferences _prefs;
  final SupabaseClient _supabaseClient;

  static const _cartKey = 'winger_guest_cart';

  CartRepositoryImpl({
    required SharedPreferences prefs,
    required SupabaseClient supabaseClient,
  })  : _prefs = prefs,
        _supabaseClient = supabaseClient;

  @override
  Future<Result<Cart, Failure>> getCart() async {
    return safeCall(
      () async {
        final jsonStr = _prefs.getString(_cartKey);
        if (jsonStr == null || jsonStr.isEmpty) {
          return const Cart();
        }
        final Map<String, dynamic> decoded = jsonDecode(jsonStr);
        return Cart.fromJson(decoded);
      },
      feature: 'CART',
      operation: 'GET_CART',
    );
  }

  @override
  Future<Result<Cart, Failure>> addItem(CartItem item) async {
    return safeCall(
      () async {
        final currentCartResult = await getCart();
        final currentCart = currentCartResult.valueOrNull ?? const Cart();

        final items = List<CartItem>.from(currentCart.items);
        final existingIndex = items.indexWhere((i) =>
            i.productId == item.productId && i.variantId == item.variantId);

        if (existingIndex >= 0) {
          final existing = items[existingIndex];
          items[existingIndex] =
              existing.copyWith(quantity: existing.quantity + item.quantity);
        } else {
          items.add(item);
        }

        final updatedCart =
            currentCart.copyWith(items: items, isValidated: false);
        await _saveCart(updatedCart);
        return updatedCart;
      },
      feature: 'CART',
      operation: 'ADD_ITEM',
    );
  }

  @override
  Future<Result<Cart, Failure>> updateQuantity(
      String itemId, int quantity) async {
    return safeCall(
      () async {
        final currentCartResult = await getCart();
        final currentCart = currentCartResult.valueOrNull ?? const Cart();

        if (quantity <= 0) {
          return (await removeItem(itemId)).valueOrNull ?? currentCart;
        }

        final items = currentCart.items.map((i) {
          if (i.id == itemId || i.productId == itemId) {
            return i.copyWith(quantity: quantity);
          }
          return i;
        }).toList();

        final updatedCart =
            currentCart.copyWith(items: items, isValidated: false);
        await _saveCart(updatedCart);
        return updatedCart;
      },
      feature: 'CART',
      operation: 'UPDATE_QUANTITY',
    );
  }

  @override
  Future<Result<Cart, Failure>> removeItem(String itemId) async {
    return safeCall(
      () async {
        final currentCartResult = await getCart();
        final currentCart = currentCartResult.valueOrNull ?? const Cart();

        final items = currentCart.items
            .where((i) => i.id != itemId && i.productId != itemId)
            .toList();
        final updatedCart =
            currentCart.copyWith(items: items, isValidated: false);
        await _saveCart(updatedCart);
        return updatedCart;
      },
      feature: 'CART',
      operation: 'REMOVE_ITEM',
    );
  }

  @override
  Future<Result<Cart, Failure>> clearCart() async {
    return safeCall(
      () async {
        const emptyCart = Cart();
        await _saveCart(emptyCart);
        return emptyCart;
      },
      feature: 'CART',
      operation: 'CLEAR_CART',
    );
  }

  @override
  Future<Result<Cart, Failure>> setAffiliateCode(String? affiliateCode) async {
    return safeCall(
      () async {
        final currentCartResult = await getCart();
        final currentCart = currentCartResult.valueOrNull ?? const Cart();
        final updatedCart = currentCart.copyWith(affiliateCode: affiliateCode);
        await _saveCart(updatedCart);
        return updatedCart;
      },
      feature: 'CART',
      operation: 'SET_AFFILIATE',
    );
  }

  @override
  Future<Result<CartValidationResult, Failure>> validateCart(Cart cart) async {
    return safeCall(
      () async {
        try {
          // Attempt Backend V2 postgrest RPC validation
          final productIds = cart.items.map((i) => i.productId).toList();
          if (productIds.isNotEmpty) {
            final response = await _supabaseClient
                .from('products')
                .select()
                .filter('id', 'in', productIds);
            final List<dynamic> dbProducts = response as List<dynamic>;

            final validatedItems = <CartItem>[];
            bool priceChanged = false;

            for (final item in cart.items) {
              final dbProduct = dbProducts.firstWhere(
                (p) => p['id'] == item.productId,
                orElse: () => null,
              );

              if (dbProduct != null) {
                final dbPrice = (dbProduct['price'] as num).toDouble();
                if (dbPrice != item.price) priceChanged = true;
                validatedItems.add(item.copyWith(
                    price: dbPrice,
                    isAvailable: dbProduct['is_available'] as bool? ?? true));
              } else {
                validatedItems.add(item.copyWith(isAvailable: false));
              }
            }

            final validatedSubtotal =
                validatedItems.fold(0.0, (sum, i) => sum + i.itemTotal);
            return CartValidationResult(
              isValid: validatedItems.every((i) => i.isAvailable),
              validatedItems: validatedItems,
              validatedSubtotal: validatedSubtotal,
              priceHasChanged: priceChanged,
            );
          }
        } catch (_) {
          // Graceful fallback to client items if offline
        }

        return CartValidationResult(
          isValid: cart.items.every((i) => i.isAvailable),
          validatedItems: cart.items,
          validatedSubtotal: cart.subtotal,
          priceHasChanged: false,
        );
      },
      feature: 'CART',
      operation: 'VALIDATE_CART',
    );
  }

  Future<void> _saveCart(Cart cart) async {
    await _prefs.setString(_cartKey, jsonEncode(cart.toJson()));
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/cart_validation_result.dart';
import '../../domain/repositories/cart_repository.dart';

class CartController extends StateNotifier<AsyncValue<Cart>> {
  final CartRepository _repository;

  CartController(this._repository) : super(const AsyncValue.loading()) {
    loadCart();
  }

  Future<void> loadCart() async {
    state = const AsyncValue.loading();
    final result = await _repository.getCart();
    switch (result) {
      case Success(:final value):
        state = AsyncValue.data(value);
      case Error(:final failure):
        state = AsyncValue.error(failure.message, StackTrace.current);
    }
  }

  Future<void> addItem(CartItem item) async {
    final result = await _repository.addItem(item);
    switch (result) {
      case Success(:final value):
        state = AsyncValue.data(value);
      case Error(:final failure):
        state = AsyncValue.error(failure.message, StackTrace.current);
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    final result = await _repository.updateQuantity(itemId, quantity);
    switch (result) {
      case Success(:final value):
        state = AsyncValue.data(value);
      case Error(:final failure):
        state = AsyncValue.error(failure.message, StackTrace.current);
    }
  }

  Future<void> removeItem(String itemId) async {
    final result = await _repository.removeItem(itemId);
    switch (result) {
      case Success(:final value):
        state = AsyncValue.data(value);
      case Error(:final failure):
        state = AsyncValue.error(failure.message, StackTrace.current);
    }
  }

  Future<void> clearCart() async {
    final result = await _repository.clearCart();
    switch (result) {
      case Success(:final value):
        state = AsyncValue.data(value);
      case Error(:final failure):
        state = AsyncValue.error(failure.message, StackTrace.current);
    }
  }

  Future<void> setAffiliateCode(String? affiliateCode) async {
    final result = await _repository.setAffiliateCode(affiliateCode);
    switch (result) {
      case Success(:final value):
        state = AsyncValue.data(value);
      case Error(:final failure):
        state = AsyncValue.error(failure.message, StackTrace.current);
    }
  }

  Future<CartValidationResult?> validateCart() async {
    final currentCart = state.valueOrNull;
    if (currentCart == null || currentCart.isEmpty) return null;

    final result = await _repository.validateCart(currentCart);
    return result.valueOrNull;
  }
}

import '../../../../core/errors/failures.dart';
import '../entities/cart.dart';
import '../entities/cart_item.dart';
import '../entities/cart_validation_result.dart';

abstract class CartRepository {
  Future<Result<Cart, Failure>> getCart();

  Future<Result<Cart, Failure>> addItem(CartItem item);

  Future<Result<Cart, Failure>> updateQuantity(String itemId, int quantity);

  Future<Result<Cart, Failure>> removeItem(String itemId);

  Future<Result<Cart, Failure>> clearCart();

  Future<Result<Cart, Failure>> setAffiliateCode(String? affiliateCode);

  Future<Result<CartValidationResult, Failure>> validateCart(Cart cart);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winger/core/errors/failures.dart';
import 'package:winger/features/cart/domain/entities/cart.dart';
import 'package:winger/features/checkout/domain/entities/checkout_session.dart';
import 'package:winger/features/checkout/domain/entities/checkout_status.dart';
import 'package:winger/features/checkout/domain/repositories/checkout_repository.dart';

class CheckoutController extends StateNotifier<AsyncValue<CheckoutSession?>> {
  final CheckoutRepository _repository;

  CheckoutController(this._repository) : super(const AsyncValue.data(null));

  Future<CheckoutSession?> startCheckoutSession(Cart cart,
      {String? affiliateCode}) async {
    state = const AsyncValue.loading();

    final result = await _repository.createCheckoutSession(
      cart: cart,
      affiliateCode: affiliateCode ?? cart.affiliateCode,
    );

    return switch (result) {
      Success(:final value) => () {
          state = AsyncValue.data(value);
          return value;
        }(),
      Error(:final failure) => () {
          state = AsyncValue.error(failure.message, StackTrace.current);
          return null;
        }(),
    };
  }

  Future<CheckoutStatus> pollSessionStatus(String sessionId) async {
    final result = await _repository.getCheckoutSessionStatus(sessionId);
    return switch (result) {
      Success(:final value) => () {
          state = AsyncValue.data(value);
          return value.status;
        }(),
      Error() => CheckoutStatus.failed,
    };
  }
}

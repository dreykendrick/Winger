import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winger/core/network/supabase_client_provider.dart';
import 'package:winger/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:winger/features/checkout/domain/entities/checkout_session.dart';
import 'package:winger/features/checkout/domain/entities/customer_info.dart';
import 'package:winger/features/checkout/domain/entities/delivery_info.dart';
import 'package:winger/features/checkout/domain/entities/delivery_option.dart';
import 'package:winger/features/checkout/domain/entities/payment_method.dart';
import 'package:winger/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:winger/features/checkout/presentation/controllers/checkout_controller.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  return CheckoutRepositoryImpl(supabaseClient: SupabaseService.client);
});

final checkoutControllerProvider =
    StateNotifierProvider<CheckoutController, AsyncValue<CheckoutSession?>>(
        (ref) {
  final repository = ref.watch(checkoutRepositoryProvider);
  return CheckoutController(repository);
});

final customerInfoStateProvider = StateProvider<CustomerInfo?>((ref) => null);

final deliveryInfoStateProvider = StateProvider<DeliveryInfo?>((ref) => null);

final selectedDeliveryOptionProvider =
    StateProvider<DeliveryOption?>((ref) => null);

final selectedPaymentMethodProvider =
    StateProvider<PaymentMethod?>((ref) => null);

final deliveryOptionsProvider =
    FutureProvider.family<List<DeliveryOption>, String>((ref, sessionId) async {
  final repository = ref.watch(checkoutRepositoryProvider);
  final result = await repository.getDeliveryOptions(sessionId);
  return result.valueOrNull ?? const [];
});

final paymentMethodsProvider = FutureProvider<List<PaymentMethod>>((ref) async {
  final repository = ref.watch(checkoutRepositoryProvider);
  final result = await repository.getPaymentMethods();
  return result.valueOrNull ?? const [];
});

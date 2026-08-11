import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winger/core/network/supabase_client_provider.dart';
import '../../data/repositories/orders_repository_impl.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepositoryImpl(supabaseClient: SupabaseService.client);
});

final guestOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final repository = ref.watch(ordersRepositoryProvider);
  final result = await repository.getGuestOrders();
  return result.valueOrNull ?? const [];
});

final orderDetailProvider =
    FutureProvider.family<Order?, String>((ref, orderId) async {
  final repository = ref.watch(ordersRepositoryProvider);
  final result = await repository.getOrderById(orderId);
  return result.valueOrNull;
});

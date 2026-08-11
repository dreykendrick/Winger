import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers/app_providers.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import '../controllers/cart_controller.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final prefsService = ref.watch(preferencesProvider);
  return CartRepositoryImpl(
      prefs: prefsService.rawPrefs, supabaseClient: SupabaseService.client);
});

final cartControllerProvider =
    StateNotifierProvider<CartController, AsyncValue<Cart>>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return CartController(repository);
});

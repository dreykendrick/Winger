import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../data/repositories/marketplace_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/marketplace_filter.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/marketplace_repository.dart';

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepositoryImpl(supabaseClient: SupabaseService.client);
});

final categoryListProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  final result = await repository.fetchCategories();
  return result.valueOrNull ?? const [];
});

final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  final result = await repository.fetchFeaturedProducts();
  return result.valueOrNull ?? const [];
});

final marketplaceFilterProvider = StateProvider<MarketplaceFilter>((ref) {
  return const MarketplaceFilter();
});

final productListProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  final filter = ref.watch(marketplaceFilterProvider);
  final result = await repository.fetchProducts(filter: filter);
  return result.valueOrNull ?? const [];
});

final productDetailProvider =
    FutureProvider.family<Product?, String>((ref, productId) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  final result = await repository.fetchProductDetail(productId);
  return result.valueOrNull;
});

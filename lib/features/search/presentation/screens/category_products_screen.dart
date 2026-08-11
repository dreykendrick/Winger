import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:winger/features/marketplace/domain/entities/category.dart';
import 'package:winger/features/marketplace/presentation/widgets/product_card.dart';
import 'package:winger/features/search/presentation/providers/search_providers.dart';
import 'package:winger/shared/components/winger_empty_state.dart';
import 'package:winger/shared/components/winger_loading.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class CategoryProductsScreen extends ConsumerWidget {
  final String categoryId;

  const CategoryProductsScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final category = categoriesAsync.valueOrNull?.firstWhere(
      (c) => c.id == categoryId,
      orElse: () =>
          const Category(id: '', name: 'Category Products', slug: 'category'),
    );

    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(category?.name ?? 'Category Products'),
      ),
      body: resultsAsync.when(
        data: (result) {
          final products = result.products;
          if (products.isEmpty) {
            return const WingerEmptyState(
              title: 'No Products in Category',
              message: 'Check back soon for new arrivals in this category.',
              icon: Icons.inventory_2_outlined,
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(WingerTokens.space16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onTap: () => context.push('/products/${product.id}'),
              );
            },
          );
        },
        loading: () =>
            const WingerLoading(message: 'Loading category products...'),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

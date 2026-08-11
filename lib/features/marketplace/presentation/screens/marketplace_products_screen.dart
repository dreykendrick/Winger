import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:winger/features/cart/domain/entities/cart_item.dart';
import 'package:winger/features/cart/presentation/providers/cart_providers.dart';
import 'package:winger/features/marketplace/presentation/providers/marketplace_providers.dart';
import 'package:winger/features/marketplace/presentation/widgets/product_card.dart';
import 'package:winger/shared/components/winger_chip.dart';
import 'package:winger/shared/components/winger_loading.dart';
import 'package:winger/shared/components/winger_logo.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class MarketplaceProductsScreen extends ConsumerStatefulWidget {
  const MarketplaceProductsScreen({super.key});

  @override
  ConsumerState<MarketplaceProductsScreen> createState() =>
      _MarketplaceProductsScreenState();
}

class _MarketplaceProductsScreenState
    extends ConsumerState<MarketplaceProductsScreen> {
  String _selectedCategory = 'All';

  final _categories = const ['All', 'Fashion', 'Electronics', 'Beauty', 'Home'];

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);
    final cartState = ref.watch(cartControllerProvider);
    final itemCount = cartState.valueOrNull?.items.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const WingerLogo(size: 28),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => context.push('/notifications'),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: Colors.white),
                onPressed: () => context.push('/cart'),
              ),
              if (itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: WingerTokens.primaryOrange,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$itemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(WingerTokens.space16),
        children: [
          // Search Bar + Filter Tuning Button
          GestureDetector(
            onTap: () => context.push('/search'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: WingerTokens.darkSurface,
                borderRadius: BorderRadius.circular(WingerTokens.radiusMedium),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Search products...',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: WingerTokens.darkSurfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child:
                        Icon(Icons.tune, color: Colors.grey.shade300, size: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Horizontal Category Filter Chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return WingerChip(
                  label: cat,
                  isSelected: _selectedCategory == cat,
                  onTap: () => setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),
          const SizedBox(height: 18),

          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trending Products',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/category/all'),
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: WingerTokens.primaryOrange,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Product Grid (2 Columns)
          productsAsync.when(
            data: (products) {
              final filtered = _selectedCategory == 'All'
                  ? products
                  : products
                      .where((p) =>
                          p.categoryName.toLowerCase() ==
                          _selectedCategory.toLowerCase())
                      .toList();

              if (filtered.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'No products found in this category.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.64,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final product = filtered[index];
                  return ProductCard(
                    product: product,
                    onTap: () => context.push('/product/${product.id}'),
                    onAddToCart: () {
                      ref.read(cartControllerProvider.notifier).addItem(
                            CartItem.fromProduct(product),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${product.title} to cart'),
                          duration: const Duration(seconds: 2),
                          action: SnackBarAction(
                            label: 'VIEW CART',
                            textColor: WingerTokens.primaryOrange,
                            onPressed: () => context.push('/cart'),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
            loading: () =>
                const WingerLoading(message: 'Loading marketplace products...'),
            error: (err, _) => Center(
              child: Text(
                'Error loading products: $err',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

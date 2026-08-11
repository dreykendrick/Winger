import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:winger/features/cart/domain/entities/cart_item.dart';
import 'package:winger/features/cart/presentation/providers/cart_providers.dart';
import 'package:winger/features/marketplace/presentation/providers/marketplace_providers.dart';
import 'package:winger/shared/components/winger_button.dart';
import 'package:winger/shared/components/winger_loading.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool _isFavorite = false;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final currencyFormatter =
        NumberFormat.currency(symbol: 'TSh ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Affiliate product link copied to clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () => context.push('/cart'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return const Center(
              child: Text(
                'Product not found.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final commissionPercent =
              (product.affiliateCommissionRate * 100).toInt();
          final estimatedEarning =
              product.price * product.affiliateCommissionRate;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Product Image Carousel with Counter & Wishlist Heart
                    Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 1.1,
                          child: Image.network(
                            product.primaryImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: WingerTokens.darkSurfaceVariant,
                              child: const Icon(
                                Icons.shopping_bag_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        // Top Right Wishlist Heart Button
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _isFavorite = !_isFavorite),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: WingerTokens.darkSurface
                                  .withValues(alpha: 0.8),
                              child: Icon(
                                _isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFavorite
                                    ? WingerTokens.dangerCoral
                                    : Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        // Image Page Counter Indicator (1/5)
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '1/5',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(WingerTokens.space16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Badge + Availability Status Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: WingerTokens.darkSurface,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: Text(
                                  product.categoryName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: WingerTokens.primaryEmerald
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.check_circle,
                                        size: 12,
                                        color: WingerTokens.primaryEmerald),
                                    SizedBox(width: 4),
                                    Text(
                                      'In Stock',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: WingerTokens.primaryEmerald,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Title
                          Text(
                            product.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Price
                          Text(
                            currencyFormatter.format(product.price),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Commission Banner Box
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: WingerTokens.primaryEmerald
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                  WingerTokens.radiusMedium),
                              border: Border.all(
                                color: WingerTokens.primaryEmerald
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.campaign,
                                    color: WingerTokens.primaryEmerald,
                                    size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Earn up to ${currencyFormatter.format(estimatedEarning)} ($commissionPercent%)',
                                    style: const TextStyle(
                                      color: WingerTokens.primaryEmerald,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Rating & Sales Row
                          Row(
                            children: const [
                              Icon(Icons.star,
                                  color: WingerTokens.accentAmber, size: 16),
                              SizedBox(width: 4),
                              Text(
                                '4.8',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '(24 reviews) • 0 sold',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Description Header & Body
                          const Text(
                            'Product Description',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description.isNotEmpty
                                ? product.description
                                : 'Beautiful Swahili printed dress. High-quality fabric with amazing design. Perfect for all occasions.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade300,
                              height: 1.4,
                            ),
                            maxLines: _isExpanded ? null : 3,
                            overflow: _isExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                          ),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _isExpanded = !_isExpanded),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Text(
                                    _isExpanded ? 'View less' : 'View more',
                                    style: const TextStyle(
                                      color: WingerTokens.primaryOrange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    _isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: WingerTokens.primaryOrange,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Sticky Bottom Bar: Add to Cart + Buy Now Buttons
              Container(
                padding: const EdgeInsets.all(WingerTokens.space16),
                decoration: BoxDecoration(
                  color: WingerTokens.darkSurface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
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
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: WingerTokens.darkSurfaceVariant),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Add to cart',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: WingerButton(
                          label: 'Buy Now',
                          onPressed: () {
                            ref.read(cartControllerProvider.notifier).addItem(
                                  CartItem.fromProduct(product),
                                );
                            context.push('/checkout');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () =>
            const WingerLoading(message: 'Loading product details...'),
        error: (err, _) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}

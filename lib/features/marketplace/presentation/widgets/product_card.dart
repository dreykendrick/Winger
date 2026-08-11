import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(symbol: 'TSh ', decimalDigits: 0);
    final commissionPercent = (product.affiliateCommissionRate * 100).toInt();
    final estimatedEarning = product.price * product.affiliateCommissionRate;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(WingerTokens.radiusMedium),
      child: Container(
        decoration: BoxDecoration(
          color: WingerTokens.darkSurface,
          borderRadius: BorderRadius.circular(WingerTokens.radiusMedium),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Stack with Top Badges
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(WingerTokens.radiusMedium)),
                      child: Image.network(
                        product.primaryImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: WingerTokens.darkSurfaceVariant,
                          child: const Icon(Icons.shopping_bag_outlined,
                              size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  // Category Badge (Top Left - Orange)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: WingerTokens.primaryOrange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.categoryName,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  // Commission % Badge (Top Right - Green)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: WingerTokens.primaryEmerald,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$commissionPercent%',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product Details
            Padding(
              padding: const EdgeInsets.all(WingerTokens.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currencyFormatter.format(product.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Earn ${currencyFormatter.format(estimatedEarning)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: WingerTokens.primaryEmerald,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: onAddToCart ?? onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WingerTokens.primaryOrange,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Add to cart',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

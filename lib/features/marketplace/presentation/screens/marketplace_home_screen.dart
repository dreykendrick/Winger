import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:winger/features/auth/presentation/providers/auth_providers.dart';
import 'package:winger/features/marketplace/presentation/providers/marketplace_providers.dart';
import 'package:winger/shared/components/winger_card.dart';
import 'package:winger/shared/components/winger_logo.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class MarketplaceHomeScreen extends ConsumerWidget {
  const MarketplaceHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userName = user?.fullName?.split(' ').first ?? 'Dustan';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'D';
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const WingerLogo(size: 28),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => context.push('/notifications'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: WingerTokens.primaryOrange,
              child: Text(
                userInitial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(WingerTokens.space16),
        children: [
          // Role-Aware Greeting Header
          Row(
            children: [
              Text(
                'Welcome back, $userName! 👋',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Here's what's happening with your store.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 18),

          // Total Revenue Card with Trend Line Chart Preview
          WingerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Revenue',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const Icon(Icons.trending_up,
                        color: WingerTokens.primaryEmerald, size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: const [
                    Text(
                      'TSh 0',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            WingerTokens.primaryEmerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.arrow_upward,
                              size: 12, color: WingerTokens.primaryEmerald),
                          SizedBox(width: 2),
                          Text(
                            '0% vs last month',
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
                const SizedBox(height: 16),
                // Smooth Curved Line Chart Graphic Preview
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _RevenueTrendChartPainter(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3 Secondary Metric Cards Row
          Row(
            children: [
              Expanded(
                child: _SecondaryMetricCard(
                  title: 'Total Sales',
                  value: '0',
                  icon: Icons.shopping_bag_outlined,
                  badgeText: '0%',
                  badgeColor: WingerTokens.primaryEmerald,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SecondaryMetricCard(
                  title: 'Active Products',
                  value: '2',
                  icon: Icons.inventory_2_outlined,
                  badgeText: '0%',
                  badgeColor: WingerTokens.secondaryBlue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SecondaryMetricCard(
                  title: 'Under Review',
                  value: '0',
                  icon: Icons.visibility_outlined,
                  badgeText: '0%',
                  badgeColor: WingerTokens.accentAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // "Your Products" Section Header + Add Product CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Products',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => context.push('/vendor/products'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/vendor/products/create'),
                    icon: const Icon(Icons.add, size: 14, color: Colors.white),
                    label: const Text(
                      'Add Product',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WingerTokens.primaryOrange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Product List Items (Dashboard Store Items)
          productsAsync.when(
            data: (products) {
              if (products.isEmpty) {
                return WingerCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Icon(Icons.inventory,
                            size: 36, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text(
                          'No products listed yet',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Add your first store product to start selling.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () =>
                              context.push('/vendor/products/create'),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Product'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WingerTokens.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.take(4).length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _DashboardProductTile(
                    productTitle: product.title,
                    category: product.categoryName,
                    priceText: 'TSh ${product.price.toInt()}',
                    imageUrl: product.primaryImageUrl,
                    isLive: product.isAvailable,
                    onTap: () => context.push('/product/${product.id}'),
                  );
                },
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(
                    color: WingerTokens.primaryOrange),
              ),
            ),
            error: (err, _) => Center(
              child: Text('Error: $err',
                  style: const TextStyle(color: Colors.red)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SecondaryMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String badgeText;
  final Color badgeColor;

  const _SecondaryMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.badgeText,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WingerTokens.space12),
      decoration: BoxDecoration(
        color: WingerTokens.darkSurface,
        borderRadius: BorderRadius.circular(WingerTokens.radiusMedium),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: badgeColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DashboardProductTile extends StatelessWidget {
  final String productTitle;
  final String category;
  final String priceText;
  final String imageUrl;
  final bool isLive;
  final VoidCallback onTap;

  const _DashboardProductTile({
    required this.productTitle,
    required this.category,
    required this.priceText,
    required this.imageUrl,
    required this.isLive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WingerTokens.darkSurface,
        borderRadius: BorderRadius.circular(WingerTokens.radiusMedium),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 48,
            height: 48,
            color: WingerTokens.darkSurfaceVariant,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.grey,
                size: 24,
              ),
            ),
          ),
        ),
        title: Text(
          productTitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              category,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isLive
                    ? WingerTokens.primaryEmerald.withValues(alpha: 0.15)
                    : WingerTokens.accentAmber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isLive
                          ? WingerTokens.primaryEmerald
                          : WingerTokens.accentAmber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isLive ? 'Live' : 'In Stock',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isLive
                          ? WingerTokens.primaryEmerald
                          : WingerTokens.accentAmber,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: Text(
          priceText,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: WingerTokens.primaryOrange,
          ),
        ),
      ),
    );
  }
}

class _RevenueTrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = WingerTokens.primaryEmerald
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          WingerTokens.primaryEmerald.withValues(alpha: 0.3),
          WingerTokens.primaryEmerald.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.7,
      size.width * 0.5,
      size.height * 0.3,
      size.width * 0.75,
      size.height * 0.4,
    );
    path.cubicTo(
      size.width * 0.85,
      size.height * 0.45,
      size.width * 0.95,
      size.height * 0.1,
      size.width,
      size.height * 0.05,
    );

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

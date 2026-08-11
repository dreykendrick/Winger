import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/components/winger_empty_state.dart';
import '../../../../shared/components/winger_error.dart';
import '../../../../shared/components/winger_loading.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../providers/affiliate_providers.dart';
import '../widgets/affiliate_product_card.dart';

class AffiliateProductsScreen extends ConsumerWidget {
  const AffiliateProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(affiliateProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Affiliate Catalog')),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const WingerEmptyState(
              title: 'No Products Available',
              message:
                  'Check back soon for new affiliate promotional opportunities.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(WingerTokens.space16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return AffiliateProductCard(
                product: product,
                onGenerateLink: () async {
                  final repository = ref.read(affiliateRepositoryProvider);
                  await repository.generateAffiliateLink(product.productId);
                  ref.invalidate(affiliateLinksProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Generated affiliate link for ${product.title}!')),
                    );
                  }
                },
              );
            },
          );
        },
        loading: () => const WingerLoading(message: 'Loading catalog...'),
        error: (error, _) => WingerError(
          message: error.toString(),
          onRetry: () => ref.invalidate(affiliateProductsProvider),
        ),
      ),
    );
  }
}

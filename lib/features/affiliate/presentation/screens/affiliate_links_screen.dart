import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/components/winger_empty_state.dart';
import '../../../../shared/components/winger_error.dart';
import '../../../../shared/components/winger_loading.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../providers/affiliate_providers.dart';
import '../widgets/affiliate_link_tile.dart';

class AffiliateLinksScreen extends ConsumerWidget {
  const AffiliateLinksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksAsync = ref.watch(affiliateLinksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Promotional Links')),
      body: linksAsync.when(
        data: (links) {
          if (links.isEmpty) {
            return const WingerEmptyState(
              title: 'No Promotional Links',
              message:
                  'Discover products from the Affiliate Catalog to generate shareable links.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(WingerTokens.space16),
            itemCount: links.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return AffiliateLinkTile(link: links[index]);
            },
          );
        },
        loading: () => const WingerLoading(message: 'Loading links...'),
        error: (error, _) => WingerError(
          message: error.toString(),
          onRetry: () => ref.invalidate(affiliateLinksProvider),
        ),
      ),
    );
  }
}

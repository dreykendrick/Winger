import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/components/winger_empty_state.dart';
import '../../../../shared/components/winger_error.dart';
import '../../../../shared/components/winger_loading.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../providers/affiliate_providers.dart';
import '../widgets/conversion_tile.dart';

class AffiliateConversionsScreen extends ConsumerWidget {
  const AffiliateConversionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversionsAsync = ref.watch(affiliateConversionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Attributed Conversions')),
      body: conversionsAsync.when(
        data: (conversions) {
          if (conversions.isEmpty) {
            return const WingerEmptyState(
              title: 'No Conversions Yet',
              message:
                  'Share your promotional links to earn commissions on customer purchases.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(WingerTokens.space16),
            itemCount: conversions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return ConversionTile(conversion: conversions[index]);
            },
          );
        },
        loading: () => const WingerLoading(message: 'Loading conversions...'),
        error: (error, _) => WingerError(
          message: error.toString(),
          onRetry: () => ref.invalidate(affiliateConversionsProvider),
        ),
      ),
    );
  }
}

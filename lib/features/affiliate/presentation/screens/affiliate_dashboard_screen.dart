import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/components/winger_card.dart';
import '../../../../shared/components/winger_loading.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../providers/affiliate_providers.dart';
import '../widgets/affiliate_link_tile.dart';
import '../widgets/affiliate_metrics_card.dart';
import '../widgets/conversion_tile.dart';

class AffiliateDashboardScreen extends ConsumerWidget {
  const AffiliateDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(affiliateProfileProvider);
    final earningsAsync = ref.watch(affiliateEarningsProvider);
    final linksAsync = ref.watch(affiliateLinksProvider);
    final conversionsAsync = ref.watch(affiliateConversionsProvider);

    final currencyFormatter =
        NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Affiliate Dashboard')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(affiliateProfileProvider);
          ref.invalidate(affiliateEarningsProvider);
          ref.invalidate(affiliateLinksProvider);
          ref.invalidate(affiliateConversionsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(WingerTokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Partner Status & Referral Code Card
              profileAsync.when(
                data: (profile) => WingerCard(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        WingerTokens.secondaryIndigo,
                        WingerTokens.primaryEmerald
                      ]),
                      borderRadius:
                          BorderRadius.circular(WingerTokens.radiusMedium),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Winger Partner Program',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                        const SizedBox(height: 4),
                        Text('Referral Code: ${profile.referralCode}',
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: WingerTokens.space16),

              // Metrics Overview Grid
              earningsAsync.when(
                data: (earnings) => GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.1,
                  children: [
                    AffiliateMetricsCard(
                      label: 'Pending Commissions',
                      value:
                          currencyFormatter.format(earnings.pendingCommissions),
                      icon: Icons.hourglass_top,
                      color: WingerTokens.accentAmber,
                    ),
                    AffiliateMetricsCard(
                      label: 'Approved Earnings',
                      value: currencyFormatter
                          .format(earnings.approvedCommissions),
                      icon: Icons.check_circle,
                      color: WingerTokens.primaryEmerald,
                    ),
                  ],
                ),
                loading: () =>
                    const WingerLoading(message: 'Loading metrics...'),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: WingerTokens.space24),

              // Active Referral Links Preview
              const Text('Active Promotional Links',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              linksAsync.when(
                data: (links) {
                  if (links.isEmpty)
                    return const Text('No links generated yet.');
                  return Column(
                      children: links
                          .map((link) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: AffiliateLinkTile(link: link)))
                          .toList());
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: WingerTokens.space24),

              // Recent Attributed Conversions
              const Text('Recent Conversions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              conversionsAsync.when(
                data: (conversions) {
                  if (conversions.isEmpty)
                    return const Text('No conversions recorded yet.');
                  return Column(
                      children: conversions
                          .map((conv) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ConversionTile(conversion: conv)))
                          .toList());
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/components/winger_card.dart';
import '../../../../shared/components/winger_error.dart';
import '../../../../shared/components/winger_loading.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../providers/affiliate_providers.dart';

class AffiliateEarningsScreen extends ConsumerWidget {
  const AffiliateEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsAsync = ref.watch(affiliateEarningsProvider);
    final currencyFormatter =
        NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Affiliate Earnings & Payouts')),
      body: earningsAsync.when(
        data: (earnings) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(WingerTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WingerCard(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        WingerTokens.primaryEmerald,
                        WingerTokens.secondaryIndigo
                      ]),
                      borderRadius:
                          BorderRadius.circular(WingerTokens.radiusMedium),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Available Payout Balance',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormatter.format(earnings.availableEarnings),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                WingerCard(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.hourglass_top,
                            color: WingerTokens.accentAmber),
                        title: const Text('Pending Verification'),
                        trailing: Text(
                            currencyFormatter
                                .format(earnings.pendingCommissions),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.check_circle_outline,
                            color: WingerTokens.primaryEmerald),
                        title: const Text('Approved Commissions'),
                        trailing: Text(
                            currencyFormatter
                                .format(earnings.approvedCommissions),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.payments_outlined,
                            color: WingerTokens.secondaryIndigo),
                        title: const Text('Total Paid Lifetime'),
                        trailing: Text(
                            currencyFormatter.format(earnings.paidEarnings),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Commissions are approved upon Order Guardian escrow clearance. Payouts are executed according to your account withdrawal preferences.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
        loading: () => const WingerLoading(message: 'Loading earnings...'),
        error: (error, _) => WingerError(
          message: error.toString(),
          onRetry: () => ref.invalidate(affiliateEarningsProvider),
        ),
      ),
    );
  }
}

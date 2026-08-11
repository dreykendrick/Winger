import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../providers/affiliate_providers.dart';

class AffiliateSettingsScreen extends ConsumerWidget {
  const AffiliateSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(affiliateProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Affiliate Settings')),
      body: profileAsync.when(
        data: (profile) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(WingerTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WingerCard(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: WingerTokens.primaryEmerald,
                      child: Icon(Icons.loyalty, color: Colors.white),
                    ),
                    title: const Text('Referral Code'),
                    subtitle: Text(profile.referralCode,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            WingerTokens.primaryEmerald.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(WingerTokens.radiusSmall),
                      ),
                      child: Text(profile.status,
                          style: const TextStyle(
                              color: WingerTokens.primaryEmerald,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                WingerCard(
                  child: Column(
                    children: [
                      ListTile(
                        leading:
                            const Icon(Icons.notifications_active_outlined),
                        title: const Text('Conversion Notifications'),
                        subtitle: const Text(
                            'Receive alerts when customer purchases are attributed to your link'),
                        trailing: Switch(value: true, onChanged: (_) {}),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.account_balance_outlined),
                        title: const Text('Payout Account Setup'),
                        subtitle: const Text(
                            'Bank account or mobile wallet destination'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}

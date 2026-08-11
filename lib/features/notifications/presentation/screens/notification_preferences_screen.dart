import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:winger/features/notifications/domain/entities/notification_preferences.dart';
import 'package:winger/features/notifications/presentation/providers/notification_providers.dart';
import 'package:winger/shared/components/winger_card.dart';
import 'package:winger/shared/components/winger_loading.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: prefsAsync.when(
        data: (prefs) => ListView(
          padding: const EdgeInsets.all(WingerTokens.space16),
          children: [
            const Text('Manage Notification Channels',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildSwitch(
              context,
              ref,
              prefs,
              title: 'Order Status Updates',
              subtitle:
                  'Shipment tracking, delivery alerts, and order confirmations',
              value: prefs.orderUpdates,
              onChanged: (val) =>
                  _update(ref, prefs.copyWith(orderUpdates: val)),
            ),
            _buildSwitch(
              context,
              ref,
              prefs,
              title: 'Payment & Billing Alerts',
              subtitle:
                  'Selcom payment authorizations, receipt verification, and invoices',
              value: prefs.paymentUpdates,
              onChanged: (val) =>
                  _update(ref, prefs.copyWith(paymentUpdates: val)),
            ),
            _buildSwitch(
              context,
              ref,
              prefs,
              title: 'Wallet & Payout Updates',
              subtitle:
                  'Deposits, balance updates, and withdrawal status changes',
              value: prefs.walletUpdates,
              onChanged: (val) =>
                  _update(ref, prefs.copyWith(walletUpdates: val)),
            ),
            _buildSwitch(
              context,
              ref,
              prefs,
              title: 'Affiliate Activity',
              subtitle:
                  'Commission payouts, link click metrics, and referral conversions',
              value: prefs.affiliateUpdates,
              onChanged: (val) =>
                  _update(ref, prefs.copyWith(affiliateUpdates: val)),
            ),
            _buildSwitch(
              context,
              ref,
              prefs,
              title: 'Order Guardian Escrow',
              subtitle:
                  'Escrow protection window updates, dispute alerts, and release notices',
              value: prefs.guardianUpdates,
              onChanged: (val) =>
                  _update(ref, prefs.copyWith(guardianUpdates: val)),
            ),
            _buildSwitch(
              context,
              ref,
              prefs,
              title: 'System & Platform Announcements',
              subtitle:
                  'Maintenance notices, platform updates, and feature releases',
              value: prefs.systemAnnouncements,
              onChanged: (val) =>
                  _update(ref, prefs.copyWith(systemAnnouncements: val)),
            ),
          ],
        ),
        loading: () => const WingerLoading(message: 'Loading preferences...'),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSwitch(
    BuildContext context,
    WidgetRef ref,
    NotificationPreferences prefs, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: WingerCard(
        child: SwitchListTile(
          title: Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          value: value,
          // ignore: deprecated_member_use
          activeColor: WingerTokens.primaryEmerald,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> _update(WidgetRef ref, NotificationPreferences newPrefs) async {
    final repository = ref.read(notificationRepositoryProvider);
    await repository.updatePreferences(newPrefs);
    ref.invalidate(notificationPreferencesProvider);
  }
}

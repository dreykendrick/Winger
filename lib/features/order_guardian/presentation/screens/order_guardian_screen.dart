import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:winger/features/order_guardian/domain/entities/guardian_status.dart';
import 'package:winger/features/order_guardian/presentation/providers/order_guardian_providers.dart';
import 'package:winger/features/order_guardian/presentation/widgets/guardian_badge.dart';
import 'package:winger/features/order_guardian/presentation/widgets/protection_timer_widget.dart';
import 'package:winger/features/order_guardian/presentation/widgets/receipt_confirmation_button.dart';
import 'package:winger/shared/components/winger_card.dart';
import 'package:winger/shared/components/winger_loading.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class OrderGuardianScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderGuardianScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderGuardianScreen> createState() =>
      _OrderGuardianScreenState();
}

class _OrderGuardianScreenState extends ConsumerState<OrderGuardianScreen> {
  bool _isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    final infoAsync =
        ref.watch(orderGuardianProtectionProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Order Guardian Protection')),
      body: infoAsync.when(
        data: (info) {
          if (info == null) {
            return const Center(
                child: Text('Protection information unavailable.'));
          }

          final currentStatus =
              _isConfirmed ? GuardianStatus.deliveryConfirmed : info.status;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(WingerTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WingerCard(
                  child: Column(
                    children: [
                      const Icon(Icons.shield_outlined,
                          size: 56, color: WingerTokens.primaryEmerald),
                      const SizedBox(height: 12),
                      GuardianBadge(status: currentStatus),
                      const SizedBox(height: 12),
                      Text(
                        'Escrow Protected: TZS ${info.escrowAmount.toInt()}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Your funds are safely held in escrow and will only be released to the merchant after delivery is verified.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ProtectionTimerWidget(expiresAt: info.protectionExpiresAt),
                const SizedBox(height: 24),
                const Text('Escrow Audit Log',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ...info.events.map((evt) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: WingerCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(evt.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(evt.description,
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade700)),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 24),
                ReceiptConfirmationButton(
                  isConfirmed: _isConfirmed,
                  onConfirm: () async {
                    final repository =
                        ref.read(orderGuardianRepositoryProvider);
                    await repository.confirmReceipt(widget.orderId);
                    setState(() {
                      _isConfirmed = true;
                    });
                  },
                ),
                const SizedBox(height: 12),
                if (info.canDispute)
                  TextButton.icon(
                    onPressed: () =>
                        context.push('/orders/${widget.orderId}/dispute'),
                    icon: const Icon(Icons.gavel_outlined,
                        color: WingerTokens.accentAmber),
                    label: const Text('Open Customer Dispute',
                        style: TextStyle(color: WingerTokens.accentAmber)),
                  ),
              ],
            ),
          );
        },
        loading: () =>
            const WingerLoading(message: 'Loading protection status...'),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

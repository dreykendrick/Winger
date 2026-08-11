import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/components/winger_card.dart';
import '../../../../shared/components/winger_loading.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../providers/orders_providers.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final dateFormatter = DateFormat('MMM dd, yyyy @ hh:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text('Live Delivery Tracking')),
      body: orderAsync.when(
        data: (order) {
          final tracking = order?.tracking;
          if (tracking == null) {
            return const Center(
                child: Text('Tracking information not available yet.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(WingerTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WingerCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tracking.carrierName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Tracking #: ${tracking.trackingNumber}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text('Est. Delivery: ${tracking.estimatedDelivery}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: WingerTokens.primaryEmerald)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Shipment History',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ...tracking.events.map((evt) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on,
                              color: WingerTokens.primaryEmerald, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(evt.description,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                                Text(dateFormatter.format(evt.timestamp),
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          );
        },
        loading: () =>
            const WingerLoading(message: 'Loading tracking information...'),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

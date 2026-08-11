import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/components/winger_button.dart';
import '../../../../shared/components/winger_loading.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../providers/orders_providers.dart';
import '../widgets/order_financial_summary.dart';
import '../widgets/order_item_tile.dart';
import '../widgets/order_status_timeline.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: Text('Order Details — $orderId')),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Order not found.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(WingerTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OrderStatusTimeline(currentStatus: order.status),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: WingerButton(
                        label: 'Track Delivery',
                        onPressed: () =>
                            context.push('/orders/$orderId/tracking'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: WingerButton(
                        label: 'Order Guardian Status',
                        onPressed: () =>
                            context.push('/orders/$orderId/guardian'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Purchased Items',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: OrderItemTile(item: item),
                    )),
                const SizedBox(height: 16),
                OrderFinancialSummary(order: order),
              ],
            ),
          );
        },
        loading: () => const WingerLoading(message: 'Loading order details...'),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

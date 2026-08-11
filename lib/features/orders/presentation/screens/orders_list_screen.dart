import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/components/winger_chip.dart';
import '../../../../shared/components/winger_empty_state.dart';
import '../../../../shared/components/winger_loading.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../providers/orders_providers.dart';
import '../widgets/order_tile.dart';

class OrdersListScreen extends ConsumerStatefulWidget {
  const OrdersListScreen({super.key});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen> {
  String _selectedFilter = 'All';

  final _filters = const [
    'All',
    'Pending',
    'Processing',
    'Completed',
    'Cancelled'
  ];

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(guestOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => context.push('/search')),
          IconButton(icon: const Icon(Icons.tune), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  return WingerChip(
                    label: filter,
                    isSelected: _selectedFilter == filter,
                    onTap: () => setState(() => _selectedFilter = filter),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Orders Feed
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(guestOrdersProvider);
              },
              child: ordersAsync.when(
                data: (orders) {
                  if (orders.isEmpty) {
                    return const WingerEmptyState(
                      title: 'No Orders Yet',
                      message:
                          'Purchases and customer orders will appear here once placed.',
                      icon: Icons.receipt_long_outlined,
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(WingerTokens.space16),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return OrderTile(
                        order: order,
                        onTap: () => context.push('/orders/${order.id}'),
                      );
                    },
                  );
                },
                loading: () =>
                    const WingerLoading(message: 'Loading orders...'),
                error: (err, _) =>
                    Center(child: Text('Error loading orders: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

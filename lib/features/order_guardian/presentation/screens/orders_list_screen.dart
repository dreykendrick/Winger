import 'package:flutter/material.dart';
import '../../../../core/widgets/order_state_badge.dart';
import '../../../../core/theme/app_colors.dart';

class OrdersListScreen extends StatelessWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders & Escrow Holds')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          final states = ['PAID_ESCROW', 'SHIPPED', 'DELIVERED'];
          final state = states[index % states.length];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #WNG_100${index + 1}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      OrderStateBadge(state: state),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Total Amount: TZS 75,000'),
                  const SizedBox(height: 12),
                  if (state == 'PAID_ESCROW')
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accentAmber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield,
                              color: AppColors.accentAmber, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Funds safely held in Escrow until delivery.',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.accentAmber),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

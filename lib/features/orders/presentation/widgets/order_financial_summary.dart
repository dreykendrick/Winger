import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:winger/features/orders/domain/entities/order.dart';
import 'package:winger/shared/components/winger_card.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class OrderFinancialSummary extends StatelessWidget {
  final Order order;

  const OrderFinancialSummary({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0);

    return WingerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Financial & Payment Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Items Subtotal',
                  style: TextStyle(color: Colors.grey)),
              Text(currencyFormatter.format(order.subtotal)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delivery Fee', style: TextStyle(color: Colors.grey)),
              Text(currencyFormatter.format(order.deliveryFee)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Payment Status',
                  style: TextStyle(color: Colors.grey)),
              Text(order.paymentStatus.label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: WingerTokens.primaryEmerald)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Paid',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(
                currencyFormatter.format(order.totalAmount),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: WingerTokens.primaryEmerald),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

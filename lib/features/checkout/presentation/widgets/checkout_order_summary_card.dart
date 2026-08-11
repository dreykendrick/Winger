import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:winger/features/checkout/domain/entities/checkout_order_summary.dart';
import 'package:winger/shared/components/winger_card.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class CheckoutOrderSummaryCard extends StatelessWidget {
  final CheckoutOrderSummary summary;

  const CheckoutOrderSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0);

    return WingerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Order Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: Colors.grey)),
              Text(currencyFormatter.format(summary.subtotal)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delivery Fee', style: TextStyle(color: Colors.grey)),
              Text(currencyFormatter.format(summary.deliveryFee)),
            ],
          ),
          if (summary.discountAmount > 0) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Discount',
                    style: TextStyle(color: WingerTokens.primaryEmerald)),
                Text('-${currencyFormatter.format(summary.discountAmount)}',
                    style: const TextStyle(color: WingerTokens.primaryEmerald)),
              ],
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                currencyFormatter.format(summary.totalAmount),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: WingerTokens.primaryEmerald),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

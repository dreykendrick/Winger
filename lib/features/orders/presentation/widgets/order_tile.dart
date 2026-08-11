import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:winger/features/orders/domain/entities/order.dart';
import 'package:winger/features/orders/domain/entities/order_status.dart';
import 'package:winger/shared/components/winger_badge.dart';
import 'package:winger/shared/components/winger_card.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class OrderTile extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderTile({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(symbol: 'TSh ', decimalDigits: 0);
    final dateFormatter = DateFormat('MMM dd, yyyy');

    WingerBadgeType badgeType;
    switch (order.status) {
      case OrderStatus.processing:
        badgeType = WingerBadgeType.processing;
        break;
      case OrderStatus.shipped:
      case OrderStatus.delivered:
        badgeType = WingerBadgeType.completed;
        break;
      case OrderStatus.cancelled:
        badgeType = WingerBadgeType.cancelled;
        break;
      default:
        badgeType = WingerBadgeType.pending;
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(WingerTokens.radiusMedium),
      child: WingerCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white),
                ),
                WingerBadge(label: order.status.label, type: badgeType),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade400)),
                    const SizedBox(height: 2),
                    Text(
                      order.deliveryInfo != null
                          ? "${order.deliveryInfo!.district}, ${order.deliveryInfo!.region}"
                          : 'John Mwangi',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade400)),
                    const SizedBox(height: 2),
                    Text(
                      currencyFormatter.format(order.totalAmount),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade400)),
                    const SizedBox(height: 2),
                    Text(
                      dateFormatter.format(order.createdAt),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color:
                            WingerTokens.primaryEmerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Paid',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: WingerTokens.primaryEmerald)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

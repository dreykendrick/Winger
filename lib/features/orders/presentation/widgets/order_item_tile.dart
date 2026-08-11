import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:winger/features/orders/domain/entities/order_item.dart';
import 'package:winger/shared/components/winger_card.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class OrderItemTile extends StatelessWidget {
  final OrderItem item;

  const OrderItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0);

    return WingerCard(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(WingerTokens.radiusMedium),
            child: SizedBox(
              width: 60,
              height: 60,
              child: item.imageUrl.isEmpty
                  ? Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: Colors.grey))
                  : CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          Container(color: Colors.grey.shade200),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 2),
                Text('Merchant: ${item.vendorName}',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Qty: ${item.quantity}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(currencyFormatter.format(item.lineTotal),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

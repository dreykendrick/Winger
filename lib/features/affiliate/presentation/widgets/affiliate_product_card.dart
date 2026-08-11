import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/components/winger_button.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../../domain/entities/affiliate_product.dart';

class AffiliateProductCard extends StatelessWidget {
  final AffiliateProduct product;
  final VoidCallback onGenerateLink;

  const AffiliateProductCard({
    super.key,
    required this.product,
    required this.onGenerateLink,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0);

    return WingerCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(WingerTokens.radiusMedium),
            child: SizedBox(
              width: 80,
              height: 80,
              child: product.imageUrl.isEmpty
                  ? Container(
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: Colors.grey),
                    )
                  : CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey.shade200),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.image_not_supported_outlined,
                            color: Colors.grey),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text('Merchant: ${product.vendorName}',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                const SizedBox(height: 6),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currencyFormatter.format(product.price),
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(
                          'Est. Comm: ${currencyFormatter.format(product.estimatedCommission)}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: WingerTokens.primaryEmerald,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    WingerButton(
                      label: 'Promote',
                      onPressed: onGenerateLink,
                    ),
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

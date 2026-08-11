import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../../domain/entities/affiliate_link.dart';

class AffiliateLinkTile extends StatelessWidget {
  final AffiliateLink link;

  const AffiliateLinkTile({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    return WingerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(link.productTitle,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(WingerTokens.radiusSmall),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    link.trackingUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy,
                      size: 18, color: WingerTokens.primaryEmerald),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: link.trackingUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Affiliate link copied to clipboard!')),
                    );
                  },
                  tooltip: 'Copy Link',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Clicks: ${link.totalClicks}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              Text('Conversions: ${link.totalConversions}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }
}

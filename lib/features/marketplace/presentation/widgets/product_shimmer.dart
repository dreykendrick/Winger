import 'package:flutter/material.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';

class ProductShimmer extends StatelessWidget {
  const ProductShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return WingerCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(WingerTokens.radiusLarge)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(WingerTokens.space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 10, width: 60, color: Colors.grey.shade200),
                const SizedBox(height: 8),
                Container(
                    height: 14,
                    width: double.infinity,
                    color: Colors.grey.shade200),
                const SizedBox(height: 6),
                Container(height: 14, width: 100, color: Colors.grey.shade200),
                const SizedBox(height: 12),
                Container(height: 16, width: 80, color: Colors.grey.shade200),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

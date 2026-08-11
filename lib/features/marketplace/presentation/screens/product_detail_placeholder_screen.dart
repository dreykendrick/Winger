import 'package:flutter/material.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';

class ProductDetailPlaceholderScreen extends StatelessWidget {
  final String productId;

  const ProductDetailPlaceholderScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Detail ($productId)')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: WingerCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_bag_outlined,
                    size: 48, color: WingerTokens.primaryEmerald),
                const SizedBox(height: 16),
                Text('Product $productId Details',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Product SKUs & Order Guardian details placeholder.',
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

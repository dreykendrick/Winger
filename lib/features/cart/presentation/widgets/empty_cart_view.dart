import 'package:flutter/material.dart';
import '../../../../shared/components/winger_button.dart';
import '../../../../shared/components/winger_empty_state.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';

class EmptyCartView extends StatelessWidget {
  final VoidCallback onBrowseMarketplace;

  const EmptyCartView({
    super.key,
    required this.onBrowseMarketplace,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(WingerTokens.space24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const WingerEmptyState(
            title: 'Your Cart is Empty',
            message:
                'Discover items from verified merchants on the Winger Marketplace.',
            icon: Icons.shopping_bag_outlined,
          ),
          const SizedBox(height: WingerTokens.space24),
          WingerButton(
            label: 'Explore Marketplace',
            onPressed: onBrowseMarketplace,
          ),
        ],
      ),
    );
  }
}

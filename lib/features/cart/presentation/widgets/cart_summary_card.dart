import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/components/winger_button.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../../domain/entities/cart.dart';

class CartSummaryCard extends StatelessWidget {
  final Cart cart;
  final VoidCallback onProceedToCheckout;
  final bool isLoading;

  const CartSummaryCard({
    super.key,
    required this.cart,
    required this.onProceedToCheckout,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0);

    return WingerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimated Subtotal',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              Text(
                currencyFormatter.format(cart.subtotal),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          if (cart.affiliateCode != null && cart.affiliateCode!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.loyalty,
                    size: 14, color: WingerTokens.primaryEmerald),
                const SizedBox(width: 4),
                Text(
                  'Referral Applied: ${cart.affiliateCode}',
                  style: const TextStyle(
                      fontSize: 11,
                      color: WingerTokens.primaryEmerald,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          const Text(
            'Prices and availability are verified with Winger Backend before checkout.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          WingerButton(
            label: 'Proceed to Checkout',
            onPressed: onProceedToCheckout,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}

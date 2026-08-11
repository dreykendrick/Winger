import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../shared/components/winger_button.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../../../cart/presentation/providers/cart_providers.dart';

class CheckoutConfirmationScreen extends ConsumerWidget {
  final String sessionId;

  const CheckoutConfirmationScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Confirmation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WingerTokens.space24),
        child: Column(
          children: [
            WingerCard(
              child: Column(
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 64, color: WingerTokens.primaryEmerald),
                  const SizedBox(height: 16),
                  const Text('Payment Verified & Order Created!',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Checkout Session: $sessionId',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 16),
                  const Text(
                    'Your order is now secured under Order Guardian automated escrow protection.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  WingerButton(
                    label: 'Return to Marketplace',
                    onPressed: () {
                      ref.read(cartControllerProvider.notifier).clearCart();
                      context.go(RouteNames.home);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

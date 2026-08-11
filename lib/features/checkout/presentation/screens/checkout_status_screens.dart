import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/components/winger_button.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../../../cart/presentation/providers/cart_providers.dart';

class CheckoutSuccessScreen extends ConsumerWidget {
  final String? sessionId;

  const CheckoutSuccessScreen({super.key, this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Placed')),
      body: Padding(
        padding: const EdgeInsets.all(WingerTokens.space24),
        child: Center(
          child: WingerCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 64, color: WingerTokens.primaryEmerald),
                const SizedBox(height: 16),
                Text('Payment Successful!',
                    style: WingerTokens.headlineLarge(
                        Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 8),
                Text('Session ID: ${sessionId ?? "N/A"}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                const Text(
                  'Your order has been transmitted to Order Guardian for escrow verification.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 24),
                WingerButton(
                  label: 'Continue Shopping',
                  onPressed: () {
                    ref.read(cartControllerProvider.notifier).clearCart();
                    context.go(RouteNames.home);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CheckoutPendingScreen extends StatelessWidget {
  final String? sessionId;

  const CheckoutPendingScreen({super.key, this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Pending')),
      body: Padding(
        padding: const EdgeInsets.all(WingerTokens.space24),
        child: Center(
          child: WingerCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hourglass_empty,
                    size: 64, color: WingerTokens.accentAmber),
                const SizedBox(height: 16),
                Text('Payment Pending Verification',
                    style: WingerTokens.headlineLarge(
                        Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 8),
                Text('Session ID: ${sessionId ?? "N/A"}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                const Text(
                  'We are awaiting confirmation from the payment gateway.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                WingerButton(
                  label: 'Return to Home',
                  onPressed: () => context.go(RouteNames.home),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CheckoutFailedScreen extends StatelessWidget {
  final String? sessionId;

  const CheckoutFailedScreen({super.key, this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Failed')),
      body: Padding(
        padding: const EdgeInsets.all(WingerTokens.space24),
        child: Center(
          child: WingerCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.highlight_off,
                    size: 64, color: WingerTokens.dangerCoral),
                const SizedBox(height: 16),
                Text('Payment Unsuccessful',
                    style: WingerTokens.headlineLarge(
                        Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 8),
                Text('Session ID: ${sessionId ?? "N/A"}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                const Text(
                  'The transaction was cancelled or declined. Your cart remains intact.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                WingerButton(
                  label: 'Return to Cart',
                  onPressed: () => context.go(RouteNames.cart),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

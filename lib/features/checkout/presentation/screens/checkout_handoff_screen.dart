import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/components/winger_button.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../providers/checkout_providers.dart';

class CheckoutHandoffScreen extends ConsumerStatefulWidget {
  const CheckoutHandoffScreen({super.key});

  @override
  ConsumerState<CheckoutHandoffScreen> createState() =>
      _CheckoutHandoffScreenState();
}

class _CheckoutHandoffScreenState extends ConsumerState<CheckoutHandoffScreen> {
  bool _isInitializing = true;
  String? _sessionId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  Future<void> _startSession() async {
    final cart = ref.read(cartControllerProvider).valueOrNull;
    if (cart == null || cart.isEmpty) {
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Your cart is empty. Please add items before checkout.';
      });
      return;
    }

    final session = await ref
        .read(checkoutControllerProvider.notifier)
        .startCheckoutSession(cart);

    if (mounted) {
      setState(() {
        _isInitializing = false;
        if (session != null) {
          _sessionId = session.sessionId;
        } else {
          _errorMessage =
              'Unable to create checkout session. Please try again.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout Handoff')),
      body: Padding(
        padding: const EdgeInsets.all(WingerTokens.space24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isInitializing) ...[
                const CircularProgressIndicator(
                    color: WingerTokens.primaryEmerald),
                const SizedBox(height: 24),
                Text('Validating cart and reserving inventory...',
                    style: WingerTokens.headlineLarge(
                        Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 8),
                const Text(
                    'Winger Checkout System is initializing secure payment session.',
                    style: TextStyle(color: Colors.grey)),
              ] else if (_errorMessage != null) ...[
                const Icon(Icons.error_outline,
                    size: 64, color: WingerTokens.dangerCoral),
                const SizedBox(height: 16),
                Text(_errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                WingerButton(
                  label: 'Return to Cart',
                  onPressed: () => context.pop(),
                ),
              ] else ...[
                WingerCard(
                  child: Column(
                    children: [
                      const Icon(Icons.lock_outline,
                          size: 48, color: WingerTokens.primaryEmerald),
                      const SizedBox(height: 12),
                      const Text('Checkout Session Ready',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text('Session ID: $_sessionId',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 16),
                      const Text(
                        'You are being handed over to Winger Checkout System for payment execution.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      WingerButton(
                        label: 'Proceed to Contact Information',
                        onPressed: () =>
                            context.go('/checkout/$_sessionId/customer'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context
                            .go('/checkout/failed?session_id=$_sessionId'),
                        child: const Text('Cancel Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

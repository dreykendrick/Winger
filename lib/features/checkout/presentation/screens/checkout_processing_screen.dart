import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:winger/features/checkout/domain/entities/checkout_status.dart';
import 'package:winger/features/checkout/presentation/providers/checkout_providers.dart';
import 'package:winger/shared/components/winger_button.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class CheckoutProcessingScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const CheckoutProcessingScreen({super.key, required this.sessionId});

  @override
  ConsumerState<CheckoutProcessingScreen> createState() =>
      _CheckoutProcessingScreenState();
}

class _CheckoutProcessingScreenState
    extends ConsumerState<CheckoutProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _pollPaymentStatus();
  }

  Future<void> _pollPaymentStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final status = await ref
        .read(checkoutControllerProvider.notifier)
        .pollSessionStatus(widget.sessionId);

    if (mounted) {
      if (status == CheckoutStatus.completed) {
        context.go('/checkout/${widget.sessionId}/confirmation');
      } else if (status == CheckoutStatus.failed ||
          status == CheckoutStatus.cancelled) {
        context.go('/checkout/failed?session_id=${widget.sessionId}');
      } else {
        // Automatically simulate completed payment after polling
        context.go('/checkout/${widget.sessionId}/confirmation');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(WingerTokens.space24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                  color: WingerTokens.primaryEmerald),
              const SizedBox(height: 24),
              const Text(
                'Authorizing Payment...',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please approve the prompt on your mobile money phone or complete authentication with Selcom.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 32),
              WingerButton(
                label: 'Simulate Immediate Success',
                onPressed: () =>
                    context.go('/checkout/${widget.sessionId}/confirmation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

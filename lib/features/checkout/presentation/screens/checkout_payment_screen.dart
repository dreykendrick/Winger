import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:winger/features/checkout/domain/entities/checkout_order_summary.dart';
import 'package:winger/features/checkout/domain/entities/payment_method.dart';
import 'package:winger/features/checkout/presentation/providers/checkout_providers.dart';
import 'package:winger/features/checkout/presentation/widgets/checkout_order_summary_card.dart';
import 'package:winger/features/checkout/presentation/widgets/checkout_step_header.dart';
import 'package:winger/features/checkout/presentation/widgets/payment_method_tile.dart';
import 'package:winger/shared/components/winger_button.dart';
import 'package:winger/shared/components/winger_card.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class CheckoutPaymentScreen extends ConsumerWidget {
  final String sessionId;

  const CheckoutPaymentScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methodsAsync = ref.watch(paymentMethodsProvider);
    final selectedMethod = ref.watch(selectedPaymentMethodProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Guest Checkout — Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WingerTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CheckoutStepHeader(currentStep: 3),
            const SizedBox(height: 16),
            const CheckoutOrderSummaryCard(
              summary: CheckoutOrderSummary(
                subtotal: 150000.0,
                deliveryFee: 5000.0,
                totalAmount: 155000.0,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Select Payment Option',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            methodsAsync.when(
              data: (methods) => Column(
                children: methods.map((method) {
                  final isSelected = (selectedMethod?.code ??
                          (methods.isNotEmpty ? methods.first.code : '')) ==
                      method.code;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: PaymentMethodTile(
                      method: method,
                      isSelected: isSelected,
                      onTap: () {
                        ref.read(selectedPaymentMethodProvider.notifier).state =
                            method;
                      },
                    ),
                  );
                }).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            const WingerCard(
              child: Row(
                children: [
                  Icon(Icons.shield_outlined,
                      color: WingerTokens.primaryEmerald),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Escrow Protected by Order Guardian. Funds are released to merchant only after verified delivery.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            WingerButton(
              label: 'Pay & Confirm Order',
              onPressed: () async {
                final method = ref.read(selectedPaymentMethodProvider) ??
                    const PaymentMethod(
                        id: 'p1',
                        name: 'Selcom Mobile Money',
                        code: 'SELCOM_MOBILE');

                final repository = ref.read(checkoutRepositoryProvider);
                await repository.initiatePayment(
                    sessionId: sessionId, paymentMethodCode: method.code);

                if (context.mounted) {
                  context.go('/checkout/$sessionId/processing');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

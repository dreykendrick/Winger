import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:winger/features/checkout/presentation/providers/checkout_providers.dart';
import 'package:winger/features/checkout/presentation/widgets/checkout_step_header.dart';
import 'package:winger/features/checkout/presentation/widgets/customer_info_form.dart';
import 'package:winger/shared/components/winger_button.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class CheckoutCustomerInfoScreen extends ConsumerWidget {
  final String sessionId;

  const CheckoutCustomerInfoScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentInfo = ref.watch(customerInfoStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Guest Checkout — Contact Info')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WingerTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CheckoutStepHeader(currentStep: 1),
            const SizedBox(height: 16),
            CustomerInfoForm(
              initialInfo: currentInfo,
              onChanged: (info) {
                ref.read(customerInfoStateProvider.notifier).state = info;
              },
            ),
            const SizedBox(height: 24),
            WingerButton(
              label: 'Continue to Delivery',
              onPressed: () async {
                final info = ref.read(customerInfoStateProvider);
                if (info == null || !info.isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Please fill in valid name, email, and phone number.')),
                  );
                  return;
                }

                final repository = ref.read(checkoutRepositoryProvider);
                await repository.updateCustomerInfo(
                    sessionId: sessionId, customerInfo: info);

                if (context.mounted) {
                  context.push('/checkout/$sessionId/delivery');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

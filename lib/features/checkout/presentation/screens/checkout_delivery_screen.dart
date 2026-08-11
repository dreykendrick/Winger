import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:winger/features/checkout/domain/entities/delivery_info.dart';
import 'package:winger/features/checkout/domain/entities/delivery_option.dart';
import 'package:winger/features/checkout/presentation/providers/checkout_providers.dart';
import 'package:winger/features/checkout/presentation/widgets/checkout_step_header.dart';
import 'package:winger/features/checkout/presentation/widgets/delivery_options_list.dart';
import 'package:winger/shared/components/winger_button.dart';
import 'package:winger/shared/components/winger_input.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class CheckoutDeliveryScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const CheckoutDeliveryScreen({super.key, required this.sessionId});

  @override
  ConsumerState<CheckoutDeliveryScreen> createState() =>
      _CheckoutDeliveryScreenState();
}

class _CheckoutDeliveryScreenState
    extends ConsumerState<CheckoutDeliveryScreen> {
  final _regionController = TextEditingController(text: 'Dar es Salaam');
  final _districtController = TextEditingController(text: 'Kinondoni');
  final _wardController = TextEditingController(text: 'Kijitonyama');
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final optionsAsync = ref.watch(deliveryOptionsProvider(widget.sessionId));
    final selectedOption = ref.watch(selectedDeliveryOptionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Guest Checkout — Delivery')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WingerTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CheckoutStepHeader(currentStep: 2),
            const SizedBox(height: 16),
            const Text('Delivery Address',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            WingerInput(label: 'Region', controller: _regionController),
            const SizedBox(height: 8),
            WingerInput(label: 'District', controller: _districtController),
            const SizedBox(height: 8),
            WingerInput(label: 'Ward / Locality', controller: _wardController),
            const SizedBox(height: 8),
            WingerInput(
                label: 'Street & House / Landmark',
                controller: _addressController),
            const SizedBox(height: 8),
            WingerInput(
                label: 'Recipient Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 24),
            const Text('Select Delivery Speed',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            optionsAsync.when(
              data: (options) => DeliveryOptionsList(
                options: options,
                selectedOption: selectedOption ??
                    (options.isNotEmpty ? options.first : null),
                onSelected: (opt) {
                  ref.read(selectedDeliveryOptionProvider.notifier).state = opt;
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            WingerButton(
              label: 'Continue to Payment',
              onPressed: () async {
                final deliveryInfo = DeliveryInfo(
                  region: _regionController.text,
                  district: _districtController.text,
                  ward: _wardController.text,
                  streetAddress: _addressController.text,
                  contactPhone: _phoneController.text,
                );

                if (!deliveryInfo.isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Please enter valid street address and contact phone.')),
                  );
                  return;
                }

                final option = ref.read(selectedDeliveryOptionProvider) ??
                    const DeliveryOption(
                        id: 'std',
                        title: 'Standard',
                        fee: 5000.0,
                        estimatedDeliveryTime: '1-3 Days');

                final repository = ref.read(checkoutRepositoryProvider);
                await repository.updateDeliveryInfo(
                  sessionId: widget.sessionId,
                  deliveryInfo: deliveryInfo,
                  deliveryOption: option,
                );

                if (mounted) {
                  context.push('/checkout/${widget.sessionId}/payment');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

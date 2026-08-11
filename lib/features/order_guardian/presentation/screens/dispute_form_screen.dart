import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/components/winger_button.dart';
import '../../../../shared/components/winger_input.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../providers/order_guardian_providers.dart';

class DisputeFormScreen extends ConsumerStatefulWidget {
  final String orderId;

  const DisputeFormScreen({super.key, required this.orderId});

  @override
  ConsumerState<DisputeFormScreen> createState() => _DisputeFormScreenState();
}

class _DisputeFormScreenState extends ConsumerState<DisputeFormScreen> {
  final _reasonController = TextEditingController();
  final _detailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open Order Dispute')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WingerTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Order Guardian Dispute Resolution',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Submitting a dispute pauses automated escrow release for Order #${widget.orderId} while our arbitration team reviews your evidence.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            WingerInput(
              label: 'Dispute Reason',
              hint: 'Item damaged, wrong item, or not delivered',
              controller: _reasonController,
            ),
            const SizedBox(height: 12),
            WingerInput(
              label: 'Additional Details',
              hint: 'Describe what happened in detail...',
              controller: _detailsController,
            ),
            const SizedBox(height: 24),
            WingerButton(
              label: 'Submit Dispute to Order Guardian',
              onPressed: () async {
                if (_reasonController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a dispute reason.')),
                  );
                  return;
                }

                final repository = ref.read(orderGuardianRepositoryProvider);
                await repository.openDispute(
                  orderId: widget.orderId,
                  reason: _reasonController.text,
                  details: _detailsController.text,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Dispute submitted successfully. Escrow release paused.')),
                  );
                  context.pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';

class CheckoutStepHeader extends StatelessWidget {
  final int currentStep; // 1: Contact, 2: Delivery, 3: Payment

  const CheckoutStepHeader({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStep(1, 'Contact'),
          _buildDivider(1),
          _buildStep(2, 'Delivery'),
          _buildDivider(2),
          _buildStep(3, 'Payment'),
        ],
      ),
    );
  }

  Widget _buildStep(int step, String label) {
    final isActive = currentStep >= step;
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor:
              isActive ? WingerTokens.primaryEmerald : Colors.grey.shade300,
          child: Text(
            '$step',
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color:
                isActive ? WingerTokens.primaryEmerald : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(int step) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: currentStep > step
            ? WingerTokens.primaryEmerald
            : Colors.grey.shade300,
      ),
    );
  }
}

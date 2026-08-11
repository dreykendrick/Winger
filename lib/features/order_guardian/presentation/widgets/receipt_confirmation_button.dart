import 'package:flutter/material.dart';
import '../../../../shared/components/winger_button.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';

class ReceiptConfirmationButton extends StatelessWidget {
  final bool isConfirmed;
  final VoidCallback onConfirm;

  const ReceiptConfirmationButton({
    super.key,
    required this.isConfirmed,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    if (isConfirmed) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: WingerTokens.primaryEmerald.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(WingerTokens.radiusMedium),
          border: Border.all(color: WingerTokens.primaryEmerald),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: WingerTokens.primaryEmerald),
            SizedBox(width: 8),
            Text('Receipt Confirmed by Customer',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: WingerTokens.primaryEmerald)),
          ],
        ),
      );
    }

    return WingerButton(
      label: 'Confirm Package Receipt',
      onPressed: onConfirm,
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';

class PriceChangeAlert extends StatelessWidget {
  final String message;

  const PriceChangeAlert({
    super.key,
    this.message =
        'Item prices or availability have been updated by merchants.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WingerTokens.accentAmber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(WingerTokens.radiusMedium),
        border: Border.all(color: WingerTokens.accentAmber),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: WingerTokens.accentAmber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

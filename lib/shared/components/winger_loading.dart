import 'package:flutter/material.dart';
import '../design_system/tokens/design_tokens.dart';

/// Reusable Loading State Indicator component.
class WingerLoading extends StatelessWidget {
  final String? message;

  const WingerLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: WingerTokens.primaryEmerald),
          if (message != null) ...[
            const SizedBox(height: WingerTokens.space16),
            Text(message!,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ],
        ],
      ),
    );
  }
}

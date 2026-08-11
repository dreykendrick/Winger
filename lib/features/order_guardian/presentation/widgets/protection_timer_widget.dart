import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';

class ProtectionTimerWidget extends StatelessWidget {
  final DateTime expiresAt;

  const ProtectionTimerWidget({super.key, required this.expiresAt});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('EEE, MMM dd, yyyy @ hh:mm a');
    final isExpired = DateTime.now().isAfter(expiresAt);

    return WingerCard(
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: WingerTokens.primaryEmerald),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Automated Escrow Protection Window',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(
                  isExpired
                      ? 'Protection Window Expired (Auto-Release Pending)'
                      : 'Protected until: ${formatter.format(expiresAt)}',
                  style: TextStyle(
                      fontSize: 11,
                      color: isExpired
                          ? WingerTokens.accentAmber
                          : Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

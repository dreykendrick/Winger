import 'package:flutter/material.dart';
import 'package:winger/features/checkout/domain/entities/payment_method.dart';
import 'package:winger/shared/components/winger_card.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class PaymentMethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodTile({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(WingerTokens.radiusMedium),
      child: WingerCard(
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              // ignore: deprecated_member_use
              groupValue: isSelected,
              // ignore: deprecated_member_use
              onChanged: (_) => onTap(),
              activeColor: WingerTokens.primaryEmerald,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  if (method.instructions != null)
                    Text(method.instructions!,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

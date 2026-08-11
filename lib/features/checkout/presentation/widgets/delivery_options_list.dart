import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:winger/features/checkout/domain/entities/delivery_option.dart';
import 'package:winger/shared/components/winger_card.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class DeliveryOptionsList extends StatelessWidget {
  final List<DeliveryOption> options;
  final DeliveryOption? selectedOption;
  final ValueChanged<DeliveryOption> onSelected;

  const DeliveryOptionsList({
    super.key,
    required this.options,
    this.selectedOption,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0);

    return Column(
      children: options.map((option) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(
            onTap: () => onSelected(option),
            borderRadius: BorderRadius.circular(WingerTokens.radiusMedium),
            child: WingerCard(
              child: Row(
                children: [
                  Radio<String>(
                    value: option.id,
                    // ignore: deprecated_member_use
                    groupValue: selectedOption?.id,
                    // ignore: deprecated_member_use
                    onChanged: (_) => onSelected(option),
                    activeColor: WingerTokens.primaryEmerald,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(option.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(option.estimatedDeliveryTime,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Text(
                    currencyFormatter.format(option.fee),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: WingerTokens.primaryEmerald),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

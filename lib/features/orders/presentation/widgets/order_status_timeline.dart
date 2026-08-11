import 'package:flutter/material.dart';
import 'package:winger/features/orders/domain/entities/order_status.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class OrderStatusTimeline extends StatelessWidget {
  final OrderStatus currentStatus;

  const OrderStatusTimeline({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = [
      OrderStatus.paid,
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];

    final currentIndex = steps.indexOf(currentStatus);
    final activeIndex = currentIndex >= 0 ? currentIndex : 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isPassed = index <= activeIndex;
          final isLast = index == steps.length - 1;

          return Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: isPassed
                      ? WingerTokens.primaryEmerald
                      : Colors.grey.shade300,
                  child: Icon(
                    isPassed ? Icons.check : Icons.circle,
                    size: 10,
                    color: isPassed ? Colors.white : Colors.transparent,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index < activeIndex
                          ? WingerTokens.primaryEmerald
                          : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/components/winger_card.dart';
import '../../domain/entities/affiliate_conversion.dart';
import 'commission_badge.dart';

class ConversionTile extends StatelessWidget {
  final AffiliateConversion conversion;

  const ConversionTile({super.key, required this.conversion});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0);

    return WingerCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(conversion.productTitle,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text('Order ID: ${conversion.orderId}',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                Text(DateFormat.yMMMd().format(conversion.createdAt),
                    style:
                        TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CommissionBadge(status: conversion.status),
              const SizedBox(height: 4),
              Text(
                currencyFormatter.format(conversion.commissionAmount),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

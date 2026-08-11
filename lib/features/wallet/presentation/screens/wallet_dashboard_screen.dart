import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/components/winger_button.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';

class WalletDashboardScreen extends ConsumerWidget {
  const WalletDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormatter =
        NumberFormat.currency(symbol: 'TSh ', decimalDigits: 0);

    const availableBalance = 12450.0;
    const pendingBalance = 4200.0;
    const totalEarnings = 16650.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
              icon: const Icon(Icons.remove_red_eye_outlined),
              onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(WingerTokens.space16),
        children: [
          // Dominant Available Balance Card
          WingerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Available Balance',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500)),
                    Icon(Icons.account_balance_wallet_outlined,
                        color: Colors.grey.shade500, size: 24),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormatter.format(availableBalance),
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: WingerButton(
                        label: 'Withdraw',
                        icon: Icons.account_balance,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: WingerButton(
                        label: 'Transactions',
                        variant: WingerButtonVariant.secondary,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Secondary Balance Metrics
          Row(
            children: [
              Expanded(
                child: WingerCard(
                  padding: const EdgeInsets.all(WingerTokens.space12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pending Balance',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade400)),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(pendingBalance),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: WingerCard(
                  padding: const EdgeInsets.all(WingerTokens.space12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Earnings',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade400)),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(totalEarnings),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Recent Transactions Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Recent Transactions',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white)),
              Text('See all',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),

          _buildTransactionTile(
            title: 'Order #ORD-2024-1001',
            date: 'May 12, 2024',
            amountText: '+ TSh 2,500',
            subtitle: 'Commission',
            isPositive: true,
          ),
          _buildTransactionTile(
            title: 'Order #ORD-2024-1000',
            date: 'May 11, 2024',
            amountText: '+ TSh 6,000',
            subtitle: 'Commission',
            isPositive: true,
          ),
          _buildTransactionTile(
            title: 'Withdrawal to Bank',
            date: 'May 10, 2024',
            amountText: '- TSh 10,000',
            subtitle: 'Completed',
            isPositive: false,
          ),
          _buildTransactionTile(
            title: 'Order #ORD-2024-0998',
            date: 'May 10, 2024',
            amountText: '+ TSh 1,500',
            subtitle: 'Commission',
            isPositive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile({
    required String title,
    required String date,
    required String amountText,
    required String subtitle,
    required bool isPositive,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: WingerCard(
        padding: const EdgeInsets.all(WingerTokens.space12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: WingerTokens.darkSurfaceVariant,
              child: Icon(
                isPositive
                    ? Icons.shopping_cart_outlined
                    : Icons.account_balance_outlined,
                size: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(date,
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color:
                        isPositive ? WingerTokens.primaryEmerald : Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        TextStyle(fontSize: 10, color: Colors.grey.shade400)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

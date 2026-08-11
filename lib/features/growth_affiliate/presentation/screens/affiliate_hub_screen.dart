import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AffiliateHubScreen extends StatelessWidget {
  const AffiliateHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Affiliate Growth Hub')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondaryIndigo,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '30-Day Cookie Attribution Active',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Promote stores & products to earn automated commission payouts.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Performance Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Card(
              child: ListTile(
                leading: Icon(Icons.touch_app, color: AppColors.primaryEmerald),
                title: Text('Total Referral Clicks'),
                trailing: Text('1,420',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const Card(
              child: ListTile(
                leading:
                    Icon(Icons.shopping_bag, color: AppColors.secondaryIndigo),
                title: Text('Conversions'),
                trailing: Text('84 Sales',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.attach_money, color: AppColors.accentAmber),
                title: Text('Earned Commissions'),
                trailing: Text('TZS 185,000',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

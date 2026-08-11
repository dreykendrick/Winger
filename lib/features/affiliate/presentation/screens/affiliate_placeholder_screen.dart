import 'package:flutter/material.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';

class AffiliatePlaceholderScreen extends StatelessWidget {
  const AffiliatePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Affiliate Growth Hub')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: WingerCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up,
                    size: 48, color: WingerTokens.primaryEmerald),
                SizedBox(height: 16),
                Text('Affiliate Growth Placeholder',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                    '30-day attribution tracking & referral link generator placeholder.',
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

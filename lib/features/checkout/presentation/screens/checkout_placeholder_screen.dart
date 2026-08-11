import 'package:flutter/material.dart';
import '../../../../shared/components/winger_card.dart';

class CheckoutPlaceholderScreen extends StatelessWidget {
  const CheckoutPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selcom Checkout')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: WingerCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.payment, size: 48, color: Colors.indigo),
                SizedBox(height: 16),
                Text('Checkout Placeholder',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                    'Selcom Mobile Money & Card payment integration placeholder.',
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

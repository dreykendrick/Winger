import 'package:flutter/material.dart';
import '../../../../shared/components/winger_card.dart';

class AuthPlaceholderScreen extends StatelessWidget {
  const AuthPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentication')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: WingerCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 48, color: Colors.indigo),
                SizedBox(height: 16),
                Text('Authentication Feature Placeholder',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Auth flows will be implemented in Sprint B.',
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

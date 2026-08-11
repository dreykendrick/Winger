import 'package:flutter/material.dart';
import '../../../../shared/components/winger_card.dart';

class SettingsPlaceholderScreen extends StatelessWidget {
  const SettingsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Settings')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: WingerCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('App Settings Placeholder',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Theme mode, localization, and push settings placeholder.',
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

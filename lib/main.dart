import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'app/config/env_config.dart';
import 'app/providers/app_providers.dart';
import 'core/network/supabase_client_provider.dart';
import 'core/storage/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Environment Config
  try {
    await EnvConfig.load(Environment.development);
  } catch (e) {
    debugPrint('EnvConfig load note: $e');
  }

  // Initialize Supabase Backend Client
  await SupabaseService.initialize();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final prefsService = PreferencesService(prefs);

  runApp(
    ProviderScope(
      overrides: [
        preferencesProvider.overrideWithValue(prefsService),
      ],
      child: const WingerApp(),
    ),
  );
}

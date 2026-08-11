import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winger/app/app.dart';
import 'package:winger/app/config/env_config.dart';
import 'package:winger/app/providers/app_providers.dart';
import 'package:winger/core/logging/app_logger.dart';
import 'package:winger/core/network/supabase_client_provider.dart';
import 'package:winger/core/storage/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load Environment Configuration
  await EnvConfig.load(Environment.development);
  AppLogger.info(
      'Booting Winger App (${EnvConfig.appName}) in ${EnvConfig.environment.name} mode');

  // 2. Initialize SharedPreferences
  final sharedPrefs = await SharedPreferences.getInstance();
  final prefsService = PreferencesService(sharedPrefs);

  // 3. Initialize Supabase SDK
  await SupabaseService.initialize();

  // 4. Launch Application
  runApp(
    ProviderScope(
      overrides: [
        preferencesProvider.overrideWithValue(prefsService),
      ],
      child: const WingerApp(),
    ),
  );
}

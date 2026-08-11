import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment { development, staging, production }

/// Centralized Environment Configuration Manager.
class EnvConfig {
  static Environment _environment = Environment.development;

  static Environment get environment => _environment;

  static Future<void> load(Environment env) async {
    _environment = env;
    final fileName = switch (env) {
      Environment.development => '.env.development',
      Environment.staging => '.env.staging',
      Environment.production => '.env.production',
    };

    try {
      await dotenv.load(fileName: fileName);
    } catch (_) {
      try {
        await dotenv.load(fileName: '.env.example');
      } catch (_) {}
    }
  }

  static String get appName => dotenv.get('APP_NAME', fallback: 'Winger');
  static String get bundleId =>
      dotenv.get('APP_BUNDLE_ID', fallback: 'co.winger.app');
  static String get supabaseUrl => dotenv.get(
        'SUPABASE_URL',
        fallback: 'https://dqclmqbegnimtbkndrif.supabase.co',
      );
  static String get supabaseAnonKey => dotenv.get(
        'SUPABASE_ANON_KEY',
        fallback:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRxY2xtcWJlZnB...',
      );
  static String get apiBaseUrl => dotenv.get('API_BASE_URL',
      fallback: 'https://dqclmqbegnimtbkndrif.supabase.co');
  static int get apiTimeoutSeconds =>
      int.parse(dotenv.get('API_TIMEOUT_SECONDS', fallback: '15'));
  static bool get enableLogging =>
      dotenv.get('ENABLE_LOGGING', fallback: 'true') == 'true';
  static bool get enableAnalytics =>
      dotenv.get('ENABLE_ANALYTICS', fallback: 'false') == 'true';
}

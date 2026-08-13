import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/config/env_config.dart';
import '../logging/app_logger.dart';

/// Centralized Supabase initialization and client provider wrapper.
class SupabaseService {
  static SupabaseClient? _fallbackClient;

  static SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      _fallbackClient ??= SupabaseClient(
        EnvConfig.supabaseUrl,
        EnvConfig.supabaseAnonKey,
      );
      return _fallbackClient!;
    }
  }

  static Future<void> initialize() async {
    final url = EnvConfig.supabaseUrl;
    final publishableKey = EnvConfig.supabaseAnonKey;

    final isPlaceholderUrl = url.isEmpty ||
        url.contains('your-project-ref') ||
        url.contains('example.com');
    final isPlaceholderKey = publishableKey.isEmpty ||
        publishableKey.contains('your_public_anon_key') ||
        publishableKey.contains('placeholder');

    if (isPlaceholderUrl || isPlaceholderKey) {
      final errorMessage =
          'CRITICAL: Supabase credentials are missing or set to placeholder values.\n'
          'SUPABASE_URL: "$url"\n'
          'Please configure valid credentials in .env.development before running Winger.';
      AppLogger.error(errorMessage);
      throw StateError(errorMessage);
    }

    try {
      await Supabase.initialize(
        url: url,
        // ignore: deprecated_member_use
        anonKey: publishableKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
      );
      AppLogger.info(
          'Supabase SDK initialized successfully for environment: ${EnvConfig.environment.name}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize Supabase SDK',
          error: e, stackTrace: stackTrace);
      throw StateError('Failed to initialize Supabase SDK: $e');
    }
  }
}

import 'package:flutter/foundation.dart';
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

    if (url.isEmpty || publishableKey.isEmpty) {
      AppLogger.warning(
          'Supabase URL or Key is empty. Skipping initialization.');
      return;
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
      debugPrint('Supabase initialization note: $e');
      AppLogger.error('Failed to initialize Supabase SDK',
          error: e, stackTrace: stackTrace);
    }
  }
}

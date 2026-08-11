import 'package:logger/logger.dart';
import '../../app/config/env_config.dart';

/// Structured logger for Winger application.
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  static void debug(String message,
      {String? feature, String? operation, String? correlationId}) {
    if (EnvConfig.enableLogging) {
      _logger.d(_formatMessage(message,
          feature: feature,
          operation: operation,
          correlationId: correlationId));
    }
  }

  static void info(String message,
      {String? feature, String? operation, String? correlationId}) {
    if (EnvConfig.enableLogging) {
      _logger.i(_formatMessage(message,
          feature: feature,
          operation: operation,
          correlationId: correlationId));
    }
  }

  static void warning(String message,
      {String? feature, String? operation, String? correlationId}) {
    _logger.w(_formatMessage(message,
        feature: feature, operation: operation, correlationId: correlationId));
  }

  static void error(String message,
      {dynamic error,
      StackTrace? stackTrace,
      String? feature,
      String? operation,
      String? correlationId}) {
    _logger.e(
      _formatMessage(message,
          feature: feature, operation: operation, correlationId: correlationId),
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void critical(String message,
      {dynamic error,
      StackTrace? stackTrace,
      String? feature,
      String? operation,
      String? correlationId}) {
    _logger.f(
      _formatMessage('[CRITICAL] $message',
          feature: feature, operation: operation, correlationId: correlationId),
      error: error,
      stackTrace: stackTrace,
    );
  }

  static String _formatMessage(String message,
      {String? feature, String? operation, String? correlationId}) {
    final sanitizedMessage = _sanitize(message);
    final contextParts = <String>[];
    if (feature != null) contextParts.add('Feature: $feature');
    if (operation != null) contextParts.add('Op: $operation');
    if (correlationId != null)
      contextParts.add('CorrelationID: $correlationId');

    final contextStr =
        contextParts.isNotEmpty ? ' [${contextParts.join(' | ')}]' : '';
    return '$sanitizedMessage$contextStr';
  }

  /// Sanitizes sensitive patterns (passwords, tokens, keys) from log output.
  static String _sanitize(String text) {
    return text.replaceAll(
      RegExp(r'(password|token|secret|authorization)\s*=\s*\S+',
          caseSensitive: false),
      r'$1=[REDACTED]',
    );
  }
}

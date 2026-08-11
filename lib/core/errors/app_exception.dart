/// Internal exception class hierarchy for infrastructure data sources.
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class NetworkException extends AppException {
  const NetworkException(
      [String message = 'Network connection error',
      String? code = 'NETWORK_ERROR'])
      : super(message, code: code);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException(String message,
      {this.statusCode, String? code = 'SERVER_ERROR'})
      : super(message, code: code);
}

class AuthException extends AppException {
  const AuthException(String message, {String? code = 'AUTH_ERROR'})
      : super(message, code: code);
}

class ValidationException extends AppException {
  const ValidationException(String message, {String? code = 'VALIDATION_ERROR'})
      : super(message, code: code);
}

class CacheException extends AppException {
  const CacheException(String message, {String? code = 'CACHE_ERROR'})
      : super(message, code: code);
}

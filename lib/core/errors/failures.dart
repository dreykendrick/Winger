/// Sealed class hierarchy representing normalized application failure states for UI presentation.
sealed class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

final class NetworkError extends Failure {
  const NetworkError(
      [super.message = 'No internet connection. Please check your network.'])
      : super(code: 'NETWORK_ERROR');
}

final class AuthError extends Failure {
  const AuthError([super.message = 'Authentication required. Please sign in.'])
      : super(code: 'AUTH_ERROR');
}

final class ForbiddenError extends Failure {
  const ForbiddenError(
      [super.message = 'You do not have permission to perform this action.'])
      : super(code: 'FORBIDDEN_ERROR');
}

final class NotFoundError extends Failure {
  const NotFoundError([super.message = 'Requested resource was not found.'])
      : super(code: 'NOT_FOUND_ERROR');
}

final class ValidationError extends Failure {
  const ValidationError(super.message) : super(code: 'VALIDATION_ERROR');
}

final class RateLimitError extends Failure {
  const RateLimitError(
      [super.message = 'Too many requests. Please try again in a moment.'])
      : super(code: 'RATE_LIMIT_ERROR');
}

final class ServerError extends Failure {
  final int? statusCode;
  const ServerError(super.message,
      {this.statusCode, super.code = 'SERVER_ERROR'});
}

final class TimeoutError extends Failure {
  const TimeoutError([super.message = 'Request timed out. Please try again.'])
      : super(code: 'TIMEOUT_ERROR');
}

final class OfflineError extends Failure {
  const OfflineError(
      [super.message = 'Device is offline. Showing cached data.'])
      : super(code: 'OFFLINE_ERROR');
}

final class UnknownError extends Failure {
  const UnknownError([super.message = 'An unexpected error occurred.'])
      : super(code: 'UNKNOWN_ERROR');
}

/// Sealed Result wrapper for type-safe functional error handling.
sealed class Result<S, E extends Failure> {
  const Result();

  bool get isSuccess => this is Success<S, E>;
  bool get isError => this is Error<S, E>;

  S? get valueOrNull => switch (this) {
        Success(:final value) => value,
        Error() => null,
      };

  E? get failureOrNull => switch (this) {
        Success() => null,
        Error(:final failure) => failure,
      };
}

final class Success<S, E extends Failure> extends Result<S, E> {
  final S value;
  const Success(this.value);
}

final class Error<S, E extends Failure> extends Result<S, E> {
  final E failure;
  const Error(this.failure);
}

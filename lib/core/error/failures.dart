/// Sealed class hierarchy representing domain and infrastructure failures in Winger client.
sealed class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Network connectivity issues (e.g. timeout, unreachable host).
final class NetworkFailure extends Failure {
  const NetworkFailure(
      [super.message = 'No internet connection. Please check your network.'])
      : super(code: 'NETWORK_ERROR');
}

/// Server or API response errors (e.g. 4xx, 5xx from PostgREST or Edge Functions).
final class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(
    super.message, {
    this.statusCode,
    super.code = 'SERVER_ERROR',
  });
}

/// Authentication and session failures (e.g. expired JWT, invalid credentials).
final class AuthFailure extends Failure {
  const AuthFailure(
    super.message, {
    super.code = 'AUTH_ERROR',
  });
}

/// Local cache or SQLite database failures.
final class CacheFailure extends Failure {
  const CacheFailure(
    super.message, {
    super.code = 'CACHE_ERROR',
  });
}

/// Input or validation failures.
final class ValidationFailure extends Failure {
  const ValidationFailure(
    super.message, {
    super.code = 'VALIDATION_ERROR',
  });
}

/// Result sealed wrapper for functional return types.
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

import '../errors/app_exception.dart';
import '../errors/failures.dart';
import '../logging/app_logger.dart';

/// Base Repository helper class providing safe execution wrappers for network and data operations.
abstract class BaseRepository {
  Future<Result<T, Failure>> safeCall<T>(
    Future<T> Function() call, {
    String? feature,
    String? operation,
  }) async {
    try {
      final data = await call();
      return Success(data);
    } on NetworkException catch (e) {
      AppLogger.warning(e.message, feature: feature, operation: operation);
      return Error(NetworkError(e.message));
    } on AuthException catch (e) {
      AppLogger.warning(e.message, feature: feature, operation: operation);
      return Error(AuthError(e.message));
    } on ValidationException catch (e) {
      AppLogger.warning(e.message, feature: feature, operation: operation);
      return Error(ValidationError(e.message));
    } on ServerException catch (e) {
      AppLogger.error(e.message,
          error: e, feature: feature, operation: operation);
      return Error(ServerError(e.message, statusCode: e.statusCode));
    } on AppException catch (e) {
      AppLogger.error(e.message,
          error: e, feature: feature, operation: operation);
      return Error(UnknownError(e.message));
    } catch (e, stackTrace) {
      AppLogger.critical('Unhandled Exception in Data Access',
          error: e,
          stackTrace: stackTrace,
          feature: feature,
          operation: operation);
      return Error(UnknownError(e.toString()));
    }
  }
}

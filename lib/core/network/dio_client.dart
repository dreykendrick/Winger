import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../app/config/env_config.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../logging/app_logger.dart';
import '../storage/secure_storage_service.dart';

/// Centralized Dio HTTP client engine for REST Edge Function API communication.
class DioClient {
  late final Dio dio;
  final SecureStorageService _secureStorage;
  final _uuid = const Uuid();

  DioClient({
    required SecureStorageService secureStorage,
    String? overrideBaseUrl,
  }) : _secureStorage = secureStorage {
    final baseUrl = overrideBaseUrl ?? EnvConfig.apiBaseUrl;

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: EnvConfig.apiTimeoutSeconds),
        receiveTimeout: Duration(seconds: EnvConfig.apiTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Inject Correlation ID for tracing
          final correlationId = 'corr_${_uuid.v4()}';
          options.headers[AppConstants.headerCorrelationId] = correlationId;

          // Inject Auth JWT Token
          final token = await _secureStorage.getAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers[AppConstants.headerAuthorization] = 'Bearer $token';
          }

          // Inject Workspace Context Header (Platform Law 2)
          final workspaceId = await _secureStorage.getWorkspaceId();
          if (workspaceId != null && workspaceId.isNotEmpty) {
            options.headers[AppConstants.headerWorkspaceId] = workspaceId;
          }

          AppLogger.debug(
            'HTTP ${options.method} ${options.path}',
            operation: 'API_REQUEST',
            correlationId: correlationId,
          );

          return handler.next(options);
        },
        onResponse: (response, handler) {
          final correlationId = response.requestOptions
              .headers[AppConstants.headerCorrelationId] as String?;
          AppLogger.debug(
            'HTTP ${response.statusCode} ${response.requestOptions.path}',
            operation: 'API_RESPONSE',
            correlationId: correlationId,
          );
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          final correlationId = error.requestOptions
              .headers[AppConstants.headerCorrelationId] as String?;
          AppLogger.error(
            'HTTP Error ${error.response?.statusCode} on ${error.requestOptions.path}',
            error: error.message,
            operation: 'API_ERROR',
            correlationId: correlationId,
          );

          final normalizedException = _normalizeDioError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: normalizedException,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );
  }

  AppException _normalizeDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Connection request timed out');
      case DioExceptionType.connectionError:
        return const NetworkException(
            'No internet connection or host unreachable');
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final data = error.response?.data;
        final message = (data is Map && data.containsKey('message'))
            ? data['message'].toString()
            : 'Server returned error status code $status';

        if (status == 401) {
          return AuthException(message, code: 'UNAUTHORIZED');
        } else if (status == 403) {
          return AuthException(message, code: 'FORBIDDEN');
        } else if (status == 404) {
          return ServerException(message, statusCode: 404, code: 'NOT_FOUND');
        } else if (status == 422) {
          return ValidationException(message, code: 'UNPROCESSABLE_ENTITY');
        }
        return ServerException(message, statusCode: status);
      default:
        return AppException(
            error.message ?? 'An unexpected network error occurred');
    }
  }
}

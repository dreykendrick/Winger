import 'package:flutter_test/flutter_test.dart';
import 'package:winger/core/errors/failures.dart';

void main() {
  group('Failure Sealed Hierarchy Tests', () {
    test('NetworkError instantiates with default message and code', () {
      const failure = NetworkError();
      expect(failure.code, 'NETWORK_ERROR');
      expect(failure.message, contains('No internet connection'));
    });

    test('ServerError captures status code', () {
      const failure = ServerError('Internal Gateway Error', statusCode: 502);
      expect(failure.code, 'SERVER_ERROR');
      expect(failure.statusCode, 502);
    });

    test('Result pattern matches Success and Error correctly', () {
      const Result<String, Failure> successResult = Success('Data Loaded');
      expect(successResult.isSuccess, isTrue);
      expect(successResult.valueOrNull, 'Data Loaded');

      const Result<String, Failure> errorResult =
          Error(AuthError('Invalid Session'));
      expect(errorResult.isError, isTrue);
      expect(errorResult.failureOrNull, isA<AuthError>());
    });
  });
}

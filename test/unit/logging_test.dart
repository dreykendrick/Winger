import 'package:flutter_test/flutter_test.dart';
import 'package:winger/app/config/env_config.dart';
import 'package:winger/core/logging/app_logger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLogger Tests', () {
    test(
        'Logger executes debug, info, warning, and error statements without throwing',
        () async {
      await EnvConfig.load(Environment.development);
      expect(
        () {
          AppLogger.debug('Debug message', feature: 'TEST', operation: 'RUN');
          AppLogger.info('User action logged',
              feature: 'AUTH', correlationId: 'corr_123');
          AppLogger.warning('Rate limit threshold warning', feature: 'NETWORK');
          AppLogger.error('API Error occurred',
              feature: 'CHECKOUT', error: Exception('Timeout'));
        },
        returnsNormally,
      );
    });
  });
}

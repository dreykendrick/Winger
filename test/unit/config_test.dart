import 'package:flutter_test/flutter_test.dart';
import 'package:winger/app/config/env_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EnvConfig Tests', () {
    test('Development environment configuration loads correctly', () async {
      await EnvConfig.load(Environment.development);
      expect(EnvConfig.environment, Environment.development);
      expect(EnvConfig.appName, isNotEmpty);
    });

    test('Staging environment configuration loads correctly', () async {
      await EnvConfig.load(Environment.staging);
      expect(EnvConfig.environment, Environment.staging);
      expect(EnvConfig.appName, isNotEmpty);
    });

    test('Production environment configuration loads correctly', () async {
      await EnvConfig.load(Environment.production);
      expect(EnvConfig.environment, Environment.production);
      expect(EnvConfig.appName, isNotEmpty);
    });
  });
}

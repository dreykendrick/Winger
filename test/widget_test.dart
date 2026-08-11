import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Smoke test placeholder', () {
    expect(1 + 1, equals(2));
  });
}

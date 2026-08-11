import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winger/app/app.dart';
import 'package:winger/app/config/env_config.dart';
import 'package:winger/app/providers/app_providers.dart';
import 'package:winger/core/storage/preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'App boots, initializes Riverpod scope and renders Marketplace home screen',
      (WidgetTester tester) async {
    await EnvConfig.load(Environment.development);
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();
    final prefsService = PreferencesService(sharedPrefs);

    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesProvider.overrideWithValue(prefsService),
          ],
          child: const WingerApp(),
        ),
      );
      await tester.pumpAndSettle();
    });

    expect(find.text('Log In'), findsWidgets);
  });
}

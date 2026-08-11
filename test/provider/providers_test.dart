import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winger/app/providers/app_providers.dart';
import 'package:winger/core/storage/preferences_service.dart';
import 'package:winger/core/storage/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Providers initialize and resolve dependencies correctly', () async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();
    final prefsService = PreferencesService(sharedPrefs);

    final container = ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(prefsService),
      ],
    );
    addTearDown(container.dispose);

    final storage = container.read(secureStorageProvider);
    expect(storage, isA<SecureStorageService>());

    final themeMode = container.read(appThemeModeProvider);
    expect(themeMode, equals('system'));
  });
}

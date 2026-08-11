import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences wrapper for non-sensitive local user preferences and app configuration.
class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  SharedPreferences get rawPrefs => _prefs;

  static const _keyThemeMode = 'winger_theme_mode';
  static const _keyLocale = 'winger_app_locale';
  static const _keyOnboardingCompleted = 'winger_onboarding_completed';

  Future<void> setThemeMode(String themeMode) async {
    await _prefs.setString(_keyThemeMode, themeMode);
  }

  String getThemeMode([String defaultMode = 'system']) {
    return _prefs.getString(_keyThemeMode) ?? defaultMode;
  }

  Future<void> setLocale(String locale) async {
    await _prefs.setString(_keyLocale, locale);
  }

  String getLocale([String defaultLocale = 'en']) {
    return _prefs.getString(_keyLocale) ?? defaultLocale;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_keyOnboardingCompleted, completed);
  }

  bool isOnboardingCompleted() {
    return _prefs.getBool(_keyOnboardingCompleted) ?? false;
  }
}

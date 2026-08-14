import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appPreferencesProvider = Provider<AppPreferences>((ref) {
  throw UnimplementedError('AppPreferences must be overridden in ProviderScope');
});

class AppPreferences {
  AppPreferences(this._prefs);

  static const _localeKey = 'app_locale';
  static const _themeKey = 'app_theme';

  final SharedPreferences _prefs;

  static Future<AppPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPreferences(prefs);
  }

  String? get localeCode => _prefs.getString(_localeKey);

  Future<void> setLocaleCode(String code) => _prefs.setString(_localeKey, code);

  String? get themeMode => _prefs.getString(_themeKey);

  Future<void> setThemeMode(String mode) => _prefs.setString(_themeKey, mode);
}

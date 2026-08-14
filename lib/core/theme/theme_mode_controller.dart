import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../preferences/app_preferences.dart';

final themeModeControllerProvider = NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final stored = ref.read(appPreferencesProvider).themeMode;
    if (stored == 'dark') return ThemeMode.dark;
    return ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final value = mode == ThemeMode.dark ? 'dark' : 'light';
    await ref.read(appPreferencesProvider).setThemeMode(value);
    state = mode;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../preferences/app_preferences.dart';

final localeControllerProvider = NotifierProvider<LocaleController, Locale?>(LocaleController.new);

class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    final code = ref.read(appPreferencesProvider).localeCode;
    if (code == null || code.isEmpty) return null;
    return Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    await ref.read(appPreferencesProvider).setLocaleCode(locale.languageCode);
    state = locale;
  }
}

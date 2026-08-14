import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:workforce_employee_app/core/theme/app_theme.dart';
import 'package:workforce_employee_app/l10n/app_localizations.dart';

Widget _localizedApp(Locale locale) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => Text(AppLocalizations.of(context)!.navTimeClock),
    ),
  );
}

void main() {
  testWidgets('locale switch changes nav label string', (tester) async {
    await tester.pumpWidget(_localizedApp(const Locale('en')));
    expect(find.text('Time Clock'), findsOneWidget);

    await tester.pumpWidget(_localizedApp(const Locale('am')));
    expect(find.text('የጊዜ ሰዓት'), findsOneWidget);
    expect(find.text('Time Clock'), findsNothing);
  });

  testWidgets('dark theme applies different ColorScheme brightness', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(const Locale('en')),
        darkTheme: AppTheme.dark(const Locale('en')),
        themeMode: ThemeMode.dark,
        home: Builder(
          builder: (context) {
            expect(Theme.of(context).brightness, Brightness.dark);
            expect(Theme.of(context).colorScheme.brightness, Brightness.dark);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });
}

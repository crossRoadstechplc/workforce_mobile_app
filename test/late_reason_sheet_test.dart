import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workforce_employee_app/features/attendance/presentation/late_reason_sheet.dart';
import 'package:workforce_employee_app/l10n/app_localizations.dart';

Widget _app() {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => showLateReasonSheet(context, 12),
          child: const Text('open'),
        ),
      ),
    ),
  );
}

ElevatedButton _continueButton(WidgetTester tester) {
  return tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Continue check-in'));
}

void main() {
  testWidgets('Other keeps continue disabled until a reason is typed', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(_continueButton(tester).onPressed, isNull);

    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(_continueButton(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'ab');
    await tester.pump();
    expect(_continueButton(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'bus delay');
    await tester.pump();
    expect(_continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('preset late reason enables continue without extra text', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Traffic'));
    await tester.pump();

    expect(_continueButton(tester).onPressed, isNotNull);
  });
}

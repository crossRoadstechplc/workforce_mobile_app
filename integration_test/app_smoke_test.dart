import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:workforce_employee_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('application boots to an authentication surface', (tester) async {
    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // A fresh install should land on login. A test device with persisted
    // credentials may instead restore the authenticated shell. Both mean the
    // bootstrap/session path completed without a fatal error.
    final hasLogin = find.textContaining('Login').evaluate().isNotEmpty ||
        find.textContaining('Sign in').evaluate().isNotEmpty;
    final hasHome = find.textContaining("Today's attendance").evaluate().isNotEmpty;

    expect(hasLogin || hasHome, isTrue);
  });
}

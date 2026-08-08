import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workforce_employee_app/core/widgets/app_error_view.dart';
import 'package:workforce_employee_app/core/widgets/app_skeleton.dart';

void main() {
  Future<void> pumpAtSize(WidgetTester tester, Size size, Widget child) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
    await tester.pump();
    expect(tester.takeException(), isNull);
  }

  testWidgets('error state fits narrow phone', (tester) async {
    await pumpAtSize(
      tester,
      const Size(320, 568),
      const AppErrorView(message: 'Network connection unavailable'),
    );
  });

  testWidgets('attendance skeleton fits compact and large phones', (tester) async {
    await pumpAtSize(tester, const Size(320, 568), const AttendanceCardSkeleton());
    await pumpAtSize(tester, const Size(430, 932), const AttendanceCardSkeleton());
  });
}

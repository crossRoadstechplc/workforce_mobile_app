import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workforce_employee_app/core/device/attendance_channel.dart';

void main() {
  test('phones report MOBILE', () {
    expect(attendanceClientChannelFor(TargetPlatform.android), attendanceChannelMobile);
    expect(attendanceClientChannelFor(TargetPlatform.iOS), attendanceChannelMobile);
  });

  test('computers report DESKTOP, never WEB', () {
    expect(attendanceClientChannelFor(TargetPlatform.windows), attendanceChannelDesktop);
    expect(attendanceClientChannelFor(TargetPlatform.linux), attendanceChannelDesktop);
    expect(attendanceClientChannelFor(TargetPlatform.macOS), attendanceChannelDesktop);
    expect(attendanceClientChannelFor(TargetPlatform.fuchsia), attendanceChannelDesktop);
  });
}

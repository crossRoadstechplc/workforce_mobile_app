import 'package:flutter/foundation.dart';

const attendanceChannelMobile = 'MOBILE';
const attendanceChannelDesktop = 'DESKTOP';

/// Phones and tablets report MOBILE (GPS required). Laptops/desktops — including
/// Flutter web on a computer — report DESKTOP. Never send WEB; the API only
/// accepts MOBILE or DESKTOP (WEB is aliased to DESKTOP server-side).
String attendanceClientChannelFor(TargetPlatform platform) {
  return switch (platform) {
    TargetPlatform.android || TargetPlatform.iOS => attendanceChannelMobile,
    _ => attendanceChannelDesktop,
  };
}

String attendanceClientChannel() => attendanceClientChannelFor(defaultTargetPlatform);

bool get isMobileAttendanceChannel => attendanceClientChannel() == attendanceChannelMobile;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../attendance/application/attendance_controller.dart';
import '../../attendance/application/location_preview_controller.dart';
import '../../history/application/history_controller.dart';
import '../../leave/application/leave_controller.dart';
import '../../evaluation/application/evaluation_controller.dart';
import '../../notifications/application/notification_controller.dart';
import '../../profile/application/profile_controller.dart';

Future<void> refreshTimeClock(WidgetRef ref) async {
  ref.invalidate(officeContextProvider);
  await Future.wait([
    ref.read(attendanceControllerProvider.notifier).refresh(),
    ref.read(officeContextProvider.future),
    ref.read(locationPreviewProvider.notifier).refreshPreview(),
    ref.read(notificationControllerProvider.notifier).refresh(),
    ref.read(evaluationListControllerProvider.notifier).refresh(),
  ]);
}

Future<void> refreshForRoute(WidgetRef ref, String path) async {
  if (path.startsWith('/home')) {
    await refreshTimeClock(ref);
    return;
  }
  if (path.startsWith('/history')) {
    await ref.read(historyControllerProvider.notifier).refresh();
    return;
  }
  if (path.startsWith('/leave')) {
    await ref.read(leaveControllerProvider.notifier).refresh();
    return;
  }
  if (path.startsWith('/evaluations')) {
    await ref.read(evaluationListControllerProvider.notifier).refresh();
    return;
  }
  if (path.startsWith('/profile')) {
    await ref.read(profileControllerProvider.notifier).refresh();
  }
}

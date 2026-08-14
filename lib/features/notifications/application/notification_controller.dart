import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/notifications/push_notification_service.dart';
import '../../../core/realtime/socket_service.dart';
import '../../attendance/application/attendance_controller.dart';
import '../../attendance/application/location_preview_controller.dart';
import '../../auth/application/session_controller.dart';
import '../../history/application/history_controller.dart';
import '../../leave/application/leave_controller.dart';
import '../../profile/application/profile_controller.dart';
import '../data/notification_models.dart';
import '../data/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) => NotificationRepository(ref.watch(dioProvider)));
final socketServiceProvider = Provider<SocketService>((ref) {
  final s = SocketService(ref.watch(tokenStorageProvider));
  ref.onDispose(() {
    s.dispose();
  });
  return s;
});
final pushNotificationServiceProvider = Provider<PushNotificationService>(
  (ref) => PushNotificationService(ref.watch(tokenStorageProvider), ref.watch(notificationRepositoryProvider)),
);
final notificationControllerProvider = AsyncNotifierProvider<NotificationController, NotificationPageData>(NotificationController.new);

class NotificationController extends AsyncNotifier<NotificationPageData> {
  StreamSubscription<SocketEvent>? _subscription;

  @override
  Future<NotificationPageData> build() async {
    final userId = ref.watch(sessionControllerProvider.select((s) => s.user?.id));
    if (userId == null) {
      return const NotificationPageData();
    }
    final socket = ref.read(socketServiceProvider);
    _subscription = socket.events.listen(_handleEvent);
    ref.onDispose(() => _subscription?.cancel());
    return ref.read(notificationRepositoryProvider).list();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => ref.read(notificationRepositoryProvider).list());
  }

  Future<void> markRead(String id) async {
    await ref.read(notificationRepositoryProvider).markRead(id);
    await refresh();
  }

  Future<void> markAllRead() async {
    await ref.read(notificationRepositoryProvider).markAllRead();
    await refresh();
  }

  void _handleEvent(SocketEvent event) {
    if (event.name == 'notification.created') refresh();
    if (event.name.startsWith('attendance.')) {
      ref.invalidate(attendanceControllerProvider);
      ref.invalidate(historyControllerProvider);
    }
    if (event.name.startsWith('leave.')) ref.invalidate(leaveControllerProvider);
    if (event.name == 'worksheet.reviewed') ref.invalidate(historyControllerProvider);
  }
}

final realtimeCoordinatorProvider = NotifierProvider<RealtimeCoordinator, bool>(RealtimeCoordinator.new);

class RealtimeCoordinator extends Notifier<bool> {
  @override
  bool build() {
    ref.listen(sessionControllerProvider, (previous, next) {
      _sync(previous, next);
    });
    Future.microtask(() => _sync(null, ref.read(sessionControllerProvider)));
    return false;
  }

  Future<void> _sync(SessionState? previous, SessionState next) async {
    final socket = ref.read(socketServiceProvider);
    final wasAuthed = previous?.status == SessionStatus.authenticated;
    final isAuthed = next.status == SessionStatus.authenticated;
    final userChanged = previous?.user?.id != null && next.user?.id != null && previous!.user!.id != next.user!.id;

    if (isAuthed && userChanged) {
      _invalidateUserScoped();
    }

    if (isAuthed && (!wasAuthed || userChanged)) {
      try {
        await socket.connect();
        await ref.read(pushNotificationServiceProvider).initialize();
        state = true;
      } catch (_) {
        state = false;
      }
      return;
    }

    if (wasAuthed && !isAuthed) {
      socket.disconnect();
      ref.read(locationServiceProvider).clearMockAnchor();
      ref.read(locationPreviewProvider.notifier).refreshPreview();
      _invalidateUserScoped();
      state = false;
    }
  }

  void _invalidateUserScoped() {
    ref.invalidate(attendanceControllerProvider);
    ref.invalidate(officeContextProvider);
    ref.invalidate(historyControllerProvider);
    ref.invalidate(leaveControllerProvider);
    ref.invalidate(profileControllerProvider);
    ref.invalidate(notificationControllerProvider);
  }
}

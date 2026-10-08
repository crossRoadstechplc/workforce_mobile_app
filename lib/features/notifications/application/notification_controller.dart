import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/auth/jwt_utils.dart';
import '../../../core/notifications/push_notification_service.dart';
import '../../../core/realtime/socket_service.dart';
import '../../attendance/application/attendance_controller.dart';
import '../../attendance/application/location_preview_controller.dart';
import '../../auth/application/session_controller.dart';
import '../../history/application/history_controller.dart';
import '../../leave/application/leave_controller.dart';
import '../../evaluation/application/evaluation_controller.dart';
import '../../meetings/application/meeting_controller.dart';
import '../../profile/application/profile_controller.dart';
import '../../chat/application/chat_controller.dart';
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
  Future<void>? _refreshInFlight;

  @override
  Future<NotificationPageData> build() async {
    final userId = ref.watch(sessionControllerProvider.select((s) => s.user?.id));
    if (userId == null) {
      return const NotificationPageData();
    }
    // Socket → provider updates are owned solely by [RealtimeCoordinator].
    return ref.read(notificationRepositoryProvider).list();
  }

  /// Single-flight refresh for pull-to-refresh / mark-read / Try again.
  Future<void> refresh() {
    return _refreshInFlight ??= _doRefresh().whenComplete(() => _refreshInFlight = null);
  }

  Future<void> _doRefresh() async {
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
}

final realtimeCoordinatorProvider = NotifierProvider<RealtimeCoordinator, bool>(RealtimeCoordinator.new);

/// Sole owner of socket → UI provider invalidation, plus proactive token refresh.
class RealtimeCoordinator extends Notifier<bool> {
  static const _debounceWindow = Duration(milliseconds: 250);
  static const _proactiveSkew = Duration(minutes: 1);

  StreamSubscription<SocketEvent>? _socketSubscription;
  StreamSubscription<void>? _tokenRefreshSubscription;
  Timer? _debounceTimer;
  Timer? _proactiveRefreshTimer;
  final Set<_InvalidateTarget> _pending = {};
  bool _connecting = false;

  @override
  bool build() {
    ref.onDispose(() {
      _socketSubscription?.cancel();
      _tokenRefreshSubscription?.cancel();
      _debounceTimer?.cancel();
      _proactiveRefreshTimer?.cancel();
    });
    ref.listen(sessionControllerProvider, (previous, next) {
      _sync(previous, next);
    });
    final storage = ref.read(tokenStorageProvider);
    _tokenRefreshSubscription = storage.onTokensRefreshed.listen((_) {
      unawaited(_reconnectWithFreshToken());
      unawaited(_scheduleProactiveRefresh());
    });
    Future.microtask(() => _sync(null, ref.read(sessionControllerProvider)));
    return false;
  }

  void _listenToSocket(SocketService socket) {
    _socketSubscription?.cancel();
    _socketSubscription = socket.events.listen(_handleSocketEvent);
  }

  void _handleSocketEvent(SocketEvent event) {
    final name = event.name;
    if (name == 'notification.created') {
      _queue(_InvalidateTarget.notifications);
      return;
    }
    if (name == 'checkin.reminder' || name == 'checkout.reminder') {
      _queueAll({
        _InvalidateTarget.attendance,
        _InvalidateTarget.office,
        _InvalidateTarget.notifications,
      });
      return;
    }
    if (name.startsWith('attendance.')) {
      _queueAll({
        _InvalidateTarget.attendance,
        _InvalidateTarget.office,
        _InvalidateTarget.history,
        _InvalidateTarget.leave,
      });
      return;
    }
    if (name.startsWith('leave.')) {
      _queue(_InvalidateTarget.leave);
      return;
    }
    if (name.startsWith('evaluation.')) {
      _queue(_InvalidateTarget.evaluations);
      return;
    }
    if (name.startsWith('meeting.')) {
      _queue(_InvalidateTarget.meetings);
      return;
    }
    if (name.startsWith('chat.')) {
      _queue(_InvalidateTarget.chat);
      return;
    }
    if (name == 'worksheet.reviewed') {
      _queue(_InvalidateTarget.history);
    }
  }

  void _queue(_InvalidateTarget target) {
    _pending.add(target);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceWindow, _flushInvalidations);
  }

  void _queueAll(Set<_InvalidateTarget> targets) {
    _pending.addAll(targets);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceWindow, _flushInvalidations);
  }

  void _flushInvalidations() {
    if (_pending.isEmpty) return;
    final batch = Set<_InvalidateTarget>.of(_pending);
    _pending.clear();

    // Invalidate only — never call notifier.refresh() here (avoids state write races).
    if (batch.contains(_InvalidateTarget.attendance)) {
      ref.invalidate(attendanceControllerProvider);
    }
    if (batch.contains(_InvalidateTarget.office)) {
      ref.invalidate(officeContextProvider);
    }
    if (batch.contains(_InvalidateTarget.history)) {
      ref.invalidate(historyControllerProvider);
    }
    if (batch.contains(_InvalidateTarget.leave)) {
      ref.invalidate(leaveControllerProvider);
    }
    if (batch.contains(_InvalidateTarget.evaluations)) {
      ref.invalidate(evaluationListControllerProvider);
    }
    if (batch.contains(_InvalidateTarget.meetings)) {
      ref.invalidate(meetingControllerProvider);
    }
    if (batch.contains(_InvalidateTarget.notifications)) {
      ref.invalidate(notificationControllerProvider);
    }
    if (batch.contains(_InvalidateTarget.chat)) {
      ref.invalidate(chatListControllerProvider);
    }
    if (batch.contains(_InvalidateTarget.profile)) {
      ref.invalidate(profileControllerProvider);
    }
  }

  Future<void> _reconnectWithFreshToken() async {
    if (ref.read(sessionControllerProvider).status != SessionStatus.authenticated) return;
    try {
      final socket = ref.read(socketServiceProvider);
      await socket.connect();
      _listenToSocket(socket);
      state = true;
    } catch (_) {
      state = false;
    }
  }

  /// Called when the app returns to foreground — refresh socket auth and catch up UI.
  Future<void> onAppResumed() async {
    if (ref.read(sessionControllerProvider).status != SessionStatus.authenticated) return;
    try {
      final socket = ref.read(socketServiceProvider);
      await socket.connect();
      _listenToSocket(socket);
      state = true;
      unawaited(_scheduleProactiveRefresh());
      _queueAll({
        _InvalidateTarget.attendance,
        _InvalidateTarget.office,
        _InvalidateTarget.notifications,
      });
    } catch (_) {
      state = false;
    }
  }

  Future<void> _scheduleProactiveRefresh() async {
    _proactiveRefreshTimer?.cancel();
    if (ref.read(sessionControllerProvider).status != SessionStatus.authenticated) return;

    final token = await ref.read(tokenStorageProvider).readAccessToken();
    if (token == null || token.isEmpty) return;

    final expiresAt = accessTokenExpiresAt(token);
    if (expiresAt == null) return;

    final refreshAt = expiresAt.subtract(_proactiveSkew);
    final delay = refreshAt.difference(DateTime.now().toUtc());
    if (delay <= Duration.zero) {
      await _proactiveRefreshNow();
      return;
    }

    _proactiveRefreshTimer = Timer(delay, () {
      unawaited(_proactiveRefreshNow());
    });
  }

  Future<void> _proactiveRefreshNow() async {
    if (ref.read(sessionControllerProvider).status != SessionStatus.authenticated) return;
    try {
      await ref.read(tokenRefresherProvider).refresh();
      // Successful refresh schedules the next timer via onTokensRefreshed.
    } catch (error) {
      final status = error is DioException ? error.response?.statusCode : null;
      if (status == 401 || status == 403) {
        // Backend explicitly rejected the refresh token - the session is
        // genuinely dead, so clear it.
        await ref.read(tokenStorageProvider).clear();
        return;
      }
      // Transient failure (network blip, timeout, server hiccup): keep the
      // tokens and retry shortly instead of logging the user out.
      _proactiveRefreshTimer?.cancel();
      _proactiveRefreshTimer = Timer(const Duration(seconds: 30), () {
        unawaited(_proactiveRefreshNow());
      });
    }
  }

  Future<void> _sync(SessionState? previous, SessionState next) async {
    final socket = ref.read(socketServiceProvider);
    final wasAuthed = previous?.status == SessionStatus.authenticated;
    final isAuthed = next.status == SessionStatus.authenticated;
    final userChanged = previous?.user?.id != null && next.user?.id != null && previous!.user!.id != next.user!.id;

    if (isAuthed && userChanged) {
      _invalidateUserScopedImmediate();
    }

    if (isAuthed && (!wasAuthed || userChanged)) {
      if (_connecting) return;
      _connecting = true;
      try {
        await socket.connect();
        _listenToSocket(socket);
        final push = ref.read(pushNotificationServiceProvider);
        push.onNavigate = (route) {
          final context = rootNavigatorKey.currentContext;
          if (context != null && context.mounted) context.go(route);
        };
        await push.initialize();
        state = true;
        unawaited(_scheduleProactiveRefresh());
      } catch (_) {
        state = false;
      } finally {
        _connecting = false;
      }
      return;
    }

    if (wasAuthed && !isAuthed) {
      _socketSubscription?.cancel();
      _socketSubscription = null;
      _proactiveRefreshTimer?.cancel();
      _debounceTimer?.cancel();
      _pending.clear();
      socket.disconnect();
      ref.read(locationPreviewProvider.notifier).refreshPreview();
      _invalidateUserScopedImmediate();
      state = false;
    }
  }

  void _invalidateUserScopedImmediate() {
    _debounceTimer?.cancel();
    _pending
      ..clear()
      ..addAll(_InvalidateTarget.values);
    _flushInvalidations();
  }
}

enum _InvalidateTarget {
  attendance,
  office,
  history,
  leave,
  evaluations,
  meetings,
  notifications,
  chat,
  profile,
}

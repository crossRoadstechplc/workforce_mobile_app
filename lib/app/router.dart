import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/application/session_controller.dart';
import '../features/auth/presentation/change_password_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/splash_page.dart';
import '../features/dashboard/presentation/app_shell.dart';
import '../features/dashboard/presentation/home_page.dart';
import '../features/history/presentation/history_page.dart';
import '../features/leave/presentation/leave_page.dart';
import '../features/meetings/presentation/meetings_page.dart';
import '../features/evaluation/presentation/evaluations_list_page.dart';
import '../features/evaluation/presentation/evaluation_form_page.dart';
import '../features/notifications/presentation/notifications_page.dart';
import '../features/profile/presentation/profile_page.dart';

class _RouterRefresh extends ChangeNotifier {
  void ping() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.listen<SessionState>(sessionControllerProvider, (_, __) => refresh.ping());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);
      final path = state.uri.path;
      return switch (session.status) {
        SessionStatus.checking => path == '/splash' ? null : '/splash',
        SessionStatus.unauthenticated => path == '/login' ? null : '/login',
        SessionStatus.mustChangePassword =>
          path == '/change-password' ? null : '/change-password',
        SessionStatus.authenticated =>
          path == '/login' || path == '/splash' || path == '/change-password'
              ? '/home'
              : null,
      };
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/change-password', builder: (_, __) => const ChangePasswordPage()),
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomePage()),
          GoRoute(path: '/history', builder: (_, __) => const HistoryPage()),
          GoRoute(path: '/leave', builder: (_, __) => const LeavePage()),
          GoRoute(path: '/meetings', builder: (_, __) => const MeetingsPage()),
          GoRoute(path: '/evaluations', builder: (_, __) => const EvaluationsListPage()),
          GoRoute(
            path: '/evaluations/:id',
            builder: (_, state) => EvaluationFormPage(id: state.pathParameters['id']!),
          ),
          GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsPage()),
        ],
      ),
    ],
  );
});

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
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
import '../features/settings/presentation/settings_page.dart';
import '../features/chat/presentation/chat_list_page.dart';
import '../features/chat/presentation/chat_thread_page.dart';
import '../features/chat/presentation/new_chat_page.dart';
import 'deep_links.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

class _RouterRefresh extends ChangeNotifier {
  void ping() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.listen<SessionState>(sessionControllerProvider, (_, __) => refresh.ping());
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);
      final path = state.uri.path;
      final loginQuery = state.uri.queryParameters['email'] ?? state.uri.queryParameters['login'];
      final loginTarget = loginQuery == null || loginQuery.isEmpty
          ? '/login'
          : '/login?email=${Uri.encodeQueryComponent(loginQuery)}';
      return switch (session.status) {
        // Keep /login reachable during bootstrap so invite deep links are not dropped.
        SessionStatus.checking => path == '/splash' || path == '/login' ? null : '/splash',
        SessionStatus.unauthenticated => path == '/login' ? null : loginTarget,
        SessionStatus.selectContext => path == '/login' ? null : '/login',
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
      GoRoute(
        path: '/login',
        builder: (_, state) {
          final email = state.uri.queryParameters['email'] ?? state.uri.queryParameters['login'];
          return LoginPage(initialLogin: email);
        },
      ),
      GoRoute(path: '/change-password', builder: (_, __) => const ChangePasswordPage()),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomePage()),
          GoRoute(path: '/history', builder: (_, __) => const HistoryPage()),
          GoRoute(path: '/leave', builder: (_, __) => const LeavePage()),
          GoRoute(path: '/meetings', builder: (_, __) => const MeetingsPage()),
          GoRoute(
            path: '/chat',
            builder: (_, __) => const ChatListPage(),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: rootNavigatorKey,
                builder: (_, __) => const NewChatPage(),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (_, state) => ChatThreadPage(conversationId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(path: '/evaluations', builder: (_, __) => const EvaluationsListPage()),
          GoRoute(
            path: '/evaluations/:id',
            builder: (_, state) => EvaluationFormPage(id: state.pathParameters['id']!),
          ),
          GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsPage()),
        ],
      ),
    ],
  );

  if (employeeDeepLinksSupported) {
    final appLinks = AppLinks();
    void open(Uri uri) {
      final location = employeeDeepLinkLocation(uri);
      if (location != null) router.go(location);
    }

    appLinks.getInitialLink().then((uri) {
      if (uri != null) open(uri);
    });
    final sub = appLinks.uriLinkStream.listen(open);
    ref.onDispose(sub.cancel);
  }

  return router;
});

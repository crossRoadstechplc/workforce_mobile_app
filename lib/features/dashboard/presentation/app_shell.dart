import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../notifications/application/notification_controller.dart';
import '../application/shell_refresh.dart';
import 'app_drawer.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _refreshing = false;

  Future<void> _refreshCurrentTab() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      final path = GoRouterState.of(context).uri.path;
      await refreshForRoute(ref, path);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  String _titleFor(String location, BuildContext context) {
    final l10n = context.l10n;
    if (location.startsWith('/history')) return l10n.navHistory;
    if (location.startsWith('/leave')) return l10n.navLeave;
    if (location.startsWith('/meetings')) return l10n.navMeetings;
    if (location.startsWith('/chat')) return l10n.navChat;
    if (location.startsWith('/evaluations')) return l10n.navPerformance;
    if (location.startsWith('/profile')) return l10n.navProfile;
    if (location.startsWith('/notifications')) return l10n.navNotifications;
    return l10n.navTimeClock;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final l10n = context.l10n;
    final colors = context.appColors;
    final unread = ref.watch(notificationControllerProvider).value?.unreadCount ?? 0;
    final wide = MediaQuery.sizeOf(context).width >= 840;
    final onNotifications = location.startsWith('/notifications');
    final canPopDetail = GoRouter.of(context).canPop();

    final appBar = AppBar(
      automaticallyImplyLeading: false,
      leading: wide
          ? (canPopDetail
              ? IconButton(
                  tooltip: l10n.back,
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                )
              : null)
          : Builder(
              builder: (ctx) => IconButton(
                tooltip: l10n.openMenu,
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                icon: const Icon(Icons.menu_rounded),
              ),
            ),
      title: Text(_titleFor(location, context)),
      actions: [
        if (onNotifications)
          TextButton(
            onPressed: unread == 0
                ? null
                : () => ref.read(notificationControllerProvider.notifier).markAllRead(),
            child: Text(l10n.readAll),
          ),
        IconButton(
          tooltip: l10n.refresh,
          onPressed: _refreshing ? null : _refreshCurrentTab,
          icon: _refreshing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: colors.textSecondary),
                )
              : Icon(Icons.refresh_rounded, color: colors.textSecondary),
        ),
        if (!onNotifications)
          IconButton(
            tooltip: l10n.notificationsTooltip,
            onPressed: () => context.go('/notifications'),
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 99 ? '99+' : '$unread'),
              child: Icon(Icons.notifications_outlined, color: colors.textSecondary),
            ),
          ),
        const SizedBox(width: 4),
      ],
    );

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            const AppSidebar(permanent: true),
            VerticalDivider(width: 1, thickness: 1, color: colors.border),
            Expanded(
              child: Scaffold(
                appBar: appBar,
                body: widget.child,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: const AppSidebar(),
      appBar: appBar,
      body: widget.child,
    );
  }
}

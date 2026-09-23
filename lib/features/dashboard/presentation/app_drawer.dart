import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/localization/l10n_extensions.dart';
import '../../app_update/application/app_update_controller.dart';
import '../../auth/application/session_controller.dart';
import '../../evaluation/application/evaluation_controller.dart';
import '../../leave/application/leave_controller.dart';
import '../../notifications/application/notification_controller.dart';
import '../../chat/application/chat_controller.dart';
import '../../task_operations/application/task_operations_launcher.dart';

/// Admin-dashboard-aligned sidebar palette (light + dark).
class _SidebarPalette {
  const _SidebarPalette({
    required this.background,
    required this.border,
    required this.title,
    required this.subtitle,
    required this.section,
    required this.item,
    required this.itemMuted,
    required this.hover,
    required this.active,
    required this.activeFg,
    required this.badgeBg,
    required this.badgeFg,
    required this.danger,
    required this.footer,
  });

  final Color background;
  final Color border;
  final Color title;
  final Color subtitle;
  final Color section;
  final Color item;
  final Color itemMuted;
  final Color hover;
  final Color active;
  final Color activeFg;
  final Color badgeBg;
  final Color badgeFg;
  final Color danger;
  final Color footer;

  static _SidebarPalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      // Matches admin: bg-slate-950 / text-slate-300 / border-slate-800 / blue-600 active
      return const _SidebarPalette(
        background: Color(0xFF020617),
        border: Color(0xFF1E293B),
        title: Colors.white,
        subtitle: Color(0xFF64748B),
        section: Color(0xFF64748B),
        item: Color(0xFFCBD5E1),
        itemMuted: Color(0xFF94A3B8),
        hover: Color(0xFF0F172A),
        active: Color(0xFF2563EB),
        activeFg: Colors.white,
        badgeBg: Color(0xFFDBEAFE),
        badgeFg: Color(0xFF1E40AF),
        danger: Color(0xFFF87171),
        footer: Color(0xFF64748B),
      );
    }
    return const _SidebarPalette(
      background: Colors.white,
      border: Color(0xFFE2E8F0),
      title: Color(0xFF0F172A),
      subtitle: Color(0xFF475569),
      section: Color(0xFF64748B),
      item: Color(0xFF0F172A),
      itemMuted: Color(0xFF64748B),
      hover: Color(0xFFF1F5F9),
      active: Color(0xFF2563EB),
      activeFg: Colors.white,
      badgeBg: Color(0xFFDBEAFE),
      badgeFg: Color(0xFF1E40AF),
      danger: Color(0xFFDC2626),
      footer: Color(0xFF64748B),
    );
  }
}

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key, this.permanent = false});

  final bool permanent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = _SidebarPalette.of(context);
    final content = _SidebarBody(permanent: permanent, palette: palette);

    if (permanent) {
      return SizedBox(
        width: 256,
        child: Material(
          color: palette.background,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: palette.border)),
            ),
            child: content,
          ),
        ),
      );
    }

    return Drawer(
      width: 280,
      backgroundColor: palette.background,
      surfaceTintColor: Colors.transparent,
      child: content,
    );
  }
}

class _SidebarBody extends ConsumerWidget {
  const _SidebarBody({required this.permanent, required this.palette});

  final bool permanent;
  final _SidebarPalette palette;

  void _go(BuildContext context, String path) {
    if (!permanent && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    context.go(path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final location = GoRouterState.of(context).uri.path;
    final session = ref.watch(sessionControllerProvider);
    final user = session.user;
    final orgName = user?.organizationName?.trim();
    final subtitle = (orgName != null && orgName.isNotEmpty)
        ? orgName
        : l10n.employeeWorkspace;
    final unread = ref.watch(notificationControllerProvider).value?.unreadCount ?? 0;
    final dueCount =
        ref.watch(evaluationListControllerProvider).value?.where((e) => e.needsSelfScore).length ?? 0;
    final leaveState = ref.watch(leaveControllerProvider).value;
    final leaveBadge = (leaveState?.summary.pendingRequests ?? 0) +
        (leaveState?.corrections.where((c) => c.status == 'PENDING').length ?? 0);

    return Column(
      children: [
        _SidebarHeader(subtitle: subtitle, palette: palette),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            children: [
              _SectionLabel(l10n.drawerSectionWork, palette: palette),
              _NavTile(
                palette: palette,
                icon: Icons.access_time_outlined,
                label: l10n.navTimeClock,
                selected: location.startsWith('/home'),
                onTap: () => _go(context, '/home'),
              ),
              _NavTile(
                palette: palette,
                icon: Icons.calendar_month_outlined,
                label: l10n.navHistory,
                selected: location.startsWith('/history'),
                onTap: () => _go(context, '/history'),
              ),
              _NavTile(
                palette: palette,
                icon: Icons.beach_access_outlined,
                label: l10n.navLeave,
                selected: location.startsWith('/leave'),
                badge: leaveBadge,
                onTap: () => _go(context, '/leave'),
              ),
              const SizedBox(height: 16),
              _SectionLabel(l10n.drawerSectionWorkplace, palette: palette),
              _NavTile(
                palette: palette,
                icon: Icons.meeting_room_outlined,
                label: l10n.navMeetings,
                selected: location.startsWith('/meetings'),
                onTap: () => _go(context, '/meetings'),
              ),
              _NavTile(
                palette: palette,
                icon: Icons.checklist_outlined,
                label: 'Task Operations',
                selected: false,
                onTap: () async {
                  if (!permanent && Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  try {
                    await ref.read(taskOperationsLauncherProvider).open();
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open Task Operations: $e')),
                    );
                  }
                },
              ),
              _NavTile(
                palette: palette,
                icon: Icons.forum_outlined,
                label: l10n.navChat,
                selected: location == '/chat' || location.startsWith('/chat/'),
                badge: ref.watch(chatListControllerProvider).value?.unreadTotal ?? 0,
                onTap: () => _go(context, '/chat'),
              ),
              _NavTile(
                palette: palette,
                icon: Icons.insights_outlined,
                label: l10n.navPerformance,
                selected: location.startsWith('/evaluations'),
                badge: dueCount,
                onTap: () => _go(context, '/evaluations'),
              ),
              const SizedBox(height: 16),
              _SectionLabel(l10n.drawerSectionAccount, palette: palette),
              _NavTile(
                palette: palette,
                icon: Icons.person_outline_rounded,
                label: l10n.navProfile,
                selected: location.startsWith('/profile'),
                onTap: () => _go(context, '/profile'),
              ),
              _NavTile(
                palette: palette,
                icon: Icons.settings_outlined,
                label: l10n.navSettings,
                selected: location.startsWith('/settings'),
                onTap: () => _go(context, '/settings'),
              ),
              _NavTile(
                palette: palette,
                icon: Icons.notifications_outlined,
                label: l10n.navNotifications,
                selected: location.startsWith('/notifications'),
                badge: unread,
                onTap: () => _go(context, '/notifications'),
              ),
              const SizedBox(height: 8),
              _NavTile(
                palette: palette,
                icon: Icons.logout_rounded,
                label: l10n.signOut,
                selected: false,
                danger: true,
                onTap: () async {
                  if (!permanent && context.mounted && Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  await ref.read(pushNotificationServiceProvider).unregister();
                  await ref.read(sessionControllerProvider.notifier).logout();
                },
              ),
            ],
          ),
        ),
        _SidebarFooter(palette: palette),
      ],
    );
  }
}

class _SidebarFooter extends ConsumerWidget {
  const _SidebarFooter({required this.palette});

  final _SidebarPalette palette;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final update = ref.watch(appUpdateControllerProvider);
    final showBanner = update.showSidebarBanner;
    final remote = update.remote?.androidVersion;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBanner) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              decoration: BoxDecoration(
                color: palette.badgeBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.system_update_alt_rounded, size: 16, color: palette.badgeFg),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.updateAvailableTitle,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: palette.badgeFg,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.updateLater,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: () => ref.read(appUpdateControllerProvider.notifier).dismissOptional(),
                        icon: Icon(Icons.close_rounded, size: 16, color: palette.badgeFg),
                      ),
                    ],
                  ),
                  Text(
                    l10n.updateAvailableBody,
                    style: TextStyle(fontSize: 11, height: 1.35, color: palette.badgeFg),
                  ),
                  if (remote != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${AppConfig.appVersion} → $remote',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: palette.badgeFg),
                    ),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.active,
                        foregroundColor: palette.activeFg,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () async {
                        final opened = await ref.read(appUpdateControllerProvider.notifier).openRelease();
                        if (!opened && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.updateOpenFailed)),
                          );
                        }
                      },
                      child: Text(l10n.updateNow),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            l10n.appVersionLabel(AppConfig.appVersion),
            style: TextStyle(fontSize: 12, color: palette.footer),
          ),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({required this.subtitle, required this.palette});

  final String subtitle;
  final _SidebarPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: palette.active,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.verified_user_outlined,
                      size: 16,
                      color: palette.activeFg,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Work-Force',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.title,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.subtitle,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: palette.badgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'EMPLOYEE',
                  style: TextStyle(
                    color: palette.badgeFg,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, {required this.palette});
  final String label;
  final _SidebarPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: palette.section,
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.palette,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
    this.danger = false,
  });

  final _SidebarPalette palette;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badge;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? palette.active : Colors.transparent;
    final fg = selected
        ? palette.activeFg
        : danger
            ? palette.danger
            : palette.item;
    final iconColor = selected
        ? palette.activeFg
        : danger
            ? palette.danger
            : palette.itemMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: selected ? palette.active.withValues(alpha: 0.85) : palette.hover,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ),
                if (badge > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.2)
                          : palette.active,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge > 99 ? '99+' : '$badge',
                      style: TextStyle(
                        color: palette.activeFg,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/theme_mode_controller.dart';
import '../../auth/application/session_controller.dart';
import '../../evaluation/application/evaluation_controller.dart';
import '../../notifications/application/notification_controller.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key, this.permanent = false});

  final bool permanent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final content = _SidebarBody(permanent: permanent);

    if (permanent) {
      return SizedBox(
        width: 300,
        child: Material(
          color: colors.surface,
          child: content,
        ),
      );
    }

    return Drawer(
      width: 304,
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      child: content,
    );
  }
}

class _SidebarBody extends ConsumerWidget {
  const _SidebarBody({required this.permanent});

  final bool permanent;

  void _go(BuildContext context, String path) {
    if (!permanent && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    context.go(path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final location = GoRouterState.of(context).uri.path;
    final session = ref.watch(sessionControllerProvider);
    final user = session.user;
    final name = user?.displayName ?? 'Employee';
    final email = user?.email ?? '';
    final role = user?.roles.isNotEmpty == true ? user!.roles.first : l10n.navProfile;
    final code = user?.employee?.employeeCode;
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'E';
    final unread = ref.watch(notificationControllerProvider).value?.unreadCount ?? 0;
    final dueCount = ref.watch(evaluationListControllerProvider).value?.where((e) => e.needsSelfScore).length ?? 0;
    final locale = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final languageCode = locale?.languageCode ?? 'en';
    final isDark = themeMode == ThemeMode.dark;

    return Column(
      children: [
        _SidebarHeader(
          name: name,
          email: email,
          role: role,
          employeeCode: code,
          initial: initial,
          workspaceLabel: l10n.employeeWorkspace,
          appTitle: l10n.appTitle,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
            children: [
              _SectionLabel(l10n.drawerSectionWork),
              _NavTile(
                icon: Icons.access_time_outlined,
                selectedIcon: Icons.access_time_filled,
                label: l10n.navTimeClock,
                selected: location.startsWith('/home'),
                onTap: () => _go(context, '/home'),
              ),
              _NavTile(
                icon: Icons.calendar_month_outlined,
                selectedIcon: Icons.calendar_month_rounded,
                label: l10n.navHistory,
                selected: location.startsWith('/history'),
                onTap: () => _go(context, '/history'),
              ),
              _NavTile(
                icon: Icons.beach_access_outlined,
                selectedIcon: Icons.beach_access_rounded,
                label: l10n.navLeave,
                selected: location.startsWith('/leave'),
                onTap: () => _go(context, '/leave'),
              ),
              const _SectionDivider(),
              _SectionLabel(l10n.drawerSectionWorkplace),
              _NavTile(
                icon: Icons.meeting_room_outlined,
                selectedIcon: Icons.meeting_room_rounded,
                label: l10n.navMeetings,
                selected: location.startsWith('/meetings'),
                onTap: () => _go(context, '/meetings'),
              ),
              _NavTile(
                icon: Icons.insights_outlined,
                selectedIcon: Icons.insights_rounded,
                label: l10n.navPerformance,
                selected: location.startsWith('/evaluations'),
                badge: dueCount,
                onTap: () => _go(context, '/evaluations'),
              ),
              const _SectionDivider(),
              _SectionLabel(l10n.drawerSectionAccount),
              _NavTile(
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                label: l10n.navProfile,
                selected: location.startsWith('/profile'),
                onTap: () => _go(context, '/profile'),
              ),
              _NavTile(
                icon: Icons.notifications_outlined,
                selectedIcon: Icons.notifications_rounded,
                label: l10n.navNotifications,
                selected: location.startsWith('/notifications'),
                badge: unread,
                onTap: () => _go(context, '/notifications'),
              ),
              const _SectionDivider(),
              _SectionLabel(l10n.preferences),
              const SizedBox(height: 6),
              _PreferenceBlock(
                title: l10n.settingsLanguage,
                child: _SegmentedPair(
                  leftLabel: l10n.languageEnglishShort,
                  rightLabel: l10n.languageAmharicShort,
                  leftSelected: languageCode == 'en',
                  onLeft: () => ref.read(localeControllerProvider.notifier).setLocale(const Locale('en')),
                  onRight: () => ref.read(localeControllerProvider.notifier).setLocale(const Locale('am')),
                ),
              ),
              const SizedBox(height: 10),
              _PreferenceBlock(
                title: l10n.settingsTheme,
                child: _SegmentedPair(
                  leftLabel: l10n.themeLight,
                  rightLabel: l10n.themeDark,
                  leftSelected: !isDark,
                  onLeft: () => ref.read(themeModeControllerProvider.notifier).setThemeMode(ThemeMode.light),
                  onRight: () => ref.read(themeModeControllerProvider.notifier).setThemeMode(ThemeMode.dark),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    if (!permanent && context.mounted && Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    await ref.read(pushNotificationServiceProvider).unregister();
                    await ref.read(sessionControllerProvider.notifier).logout();
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: Text(l10n.signOut),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(color: colors.error.withValues(alpha: 0.35)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({
    required this.name,
    required this.email,
    required this.role,
    required this.employeeCode,
    required this.initial,
    required this.workspaceLabel,
    required this.appTitle,
  });

  final String name;
  final String email;
  final String role;
  final String? employeeCode;
  final String initial;
  final String workspaceLabel;
  final String appTitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF0B1220) : const Color(0xFF0F172A);
    final subtitle = [
      role,
      if (employeeCode != null && employeeCode!.isNotEmpty) employeeCode,
    ].join(' · ');

    return Container(
      width: double.infinity,
      color: headerBg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF60A5FA),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    appTitle.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF93C5FD),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                workspaceLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF1D4ED8),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.9,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1, color: context.appColors.border),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? colors.primary.withValues(alpha: 0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 3,
                  height: 28,
                  decoration: BoxDecoration(
                    color: selected ? colors.primary : Colors.transparent,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  selected ? selectedIcon : icon,
                  size: 22,
                  color: selected ? colors.primary : colors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? colors.primary : colors.textPrimary,
                    ),
                  ),
                ),
                if (badge > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge > 99 ? '99+' : '$badge',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF0F172A)
                            : Colors.white,
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

class _PreferenceBlock extends StatelessWidget {
  const _PreferenceBlock({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _SegmentedPair extends StatelessWidget {
  const _SegmentedPair({
    required this.leftLabel,
    required this.rightLabel,
    required this.leftSelected,
    required this.onLeft,
    required this.onRight,
  });

  final String leftLabel;
  final String rightLabel;
  final bool leftSelected;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              label: leftLabel,
              selected: leftSelected,
              isDark: isDark,
              onTap: onLeft,
            ),
          ),
          Expanded(
            child: _Segment(
              label: rightLabel,
              selected: !leftSelected,
              isDark: isDark,
              onTap: onRight,
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? colors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        boxShadow: selected && !isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? colors.textPrimary : colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

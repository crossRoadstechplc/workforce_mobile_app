import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/theme_mode_controller.dart';
import '../../auth/application/session_controller.dart';
import '../application/shell_refresh.dart';

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

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = location.startsWith('/history')
        ? 1
        : location.startsWith('/leave')
            ? 2
            : location.startsWith('/profile')
                ? 3
                : 0;
    final session = ref.watch(sessionControllerProvider);
    final name = session.user?.displayName ?? 'Employee';
    final l10n = context.l10n;
    final colors = context.appColors;
    final locale = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final isDark = themeMode == ThemeMode.dark;
    final languageCode = locale?.languageCode ?? 'en';

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: colors.background,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                child: SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.greetingHi(name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _HeaderLanguagePill(
                        languageCode: languageCode,
                        onChanged: (code) {
                          ref.read(localeControllerProvider.notifier).setLocale(Locale(code));
                        },
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        style: IconButton.styleFrom(
                          minimumSize: const Size(40, 40),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        tooltip: l10n.refresh,
                        onPressed: _refreshing ? null : _refreshCurrentTab,
                        icon: _refreshing
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: colors.textSecondary),
                              )
                            : Icon(Icons.refresh_rounded, color: colors.textSecondary, size: 22),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        style: IconButton.styleFrom(
                          minimumSize: const Size(40, 40),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        tooltip: isDark ? l10n.themeLight : l10n.themeDark,
                        onPressed: () {
                          final next = isDark ? ThemeMode.light : ThemeMode.dark;
                          ref.read(themeModeControllerProvider.notifier).setThemeMode(next);
                        },
                        icon: Icon(
                          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                          color: colors.textSecondary,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          switch (value) {
            case 0:
              context.go('/home');
            case 1:
              context.go('/history');
            case 2:
              context.go('/leave');
            case 3:
              context.go('/profile');
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.access_time_outlined),
            selectedIcon: const Icon(Icons.access_time_filled),
            label: l10n.navTimeClock,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month_rounded),
            label: l10n.navHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.beach_access_outlined),
            selectedIcon: const Icon(Icons.beach_access_rounded),
            label: l10n.navLeave,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}

class _HeaderLanguagePill extends StatelessWidget {
  const _HeaderLanguagePill({
    required this.languageCode,
    required this.onChanged,
  });

  final String languageCode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: l10n.settingsLanguage,
      child: Container(
        height: 32,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: colors.muted.withValues(alpha: isDark ? 0.85 : 1),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PillSegment(
              label: l10n.languageEnglishShort,
              selected: languageCode == 'en',
              onTap: () {
                if (languageCode != 'en') onChanged('en');
              },
            ),
            _PillSegment(
              label: l10n.languageAmharicShort,
              selected: languageCode == 'am',
              onTap: () {
                if (languageCode != 'am') onChanged('am');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PillSegment extends StatelessWidget {
  const _PillSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? colors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        boxShadow: selected && !isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
        border: selected && isDark ? Border.all(color: colors.border.withValues(alpha: 0.6)) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? colors.textPrimary : colors.textSecondary,
                height: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

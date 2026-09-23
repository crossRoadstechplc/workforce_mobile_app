import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/theme_mode_controller.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../auth/application/session_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.changePassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: current,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.currentPassword),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: next,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.newPassword),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirm,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.confirmPassword),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.update)),
        ],
      ),
    );
    if (result != true) {
      current.dispose();
      next.dispose();
      confirm.dispose();
      return;
    }
    if (next.text.length < 6 || next.text != confirm.text) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.passwordRules)));
      }
      current.dispose();
      next.dispose();
      confirm.dispose();
      return;
    }
    try {
      await ref.read(sessionControllerProvider.notifier).changePassword(current.text, next.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.passwordChanged)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      current.dispose();
      next.dispose();
      confirm.dispose();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final locale = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final languageCode = locale?.languageCode ?? 'en';
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      body: ResponsiveContent(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsLanguage,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SegmentedPair(
                    leftLabel: l10n.languageEnglishShort,
                    rightLabel: l10n.languageAmharicShort,
                    leftSelected: languageCode == 'en',
                    onLeft: () => ref.read(localeControllerProvider.notifier).setLocale(const Locale('en')),
                    onRight: () => ref.read(localeControllerProvider.notifier).setLocale(const Locale('am')),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.settingsTheme,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SegmentedPair(
                    leftLabel: l10n.themeLight,
                    rightLabel: l10n.themeDark,
                    leftSelected: !isDark,
                    onLeft: () => ref.read(themeModeControllerProvider.notifier).setThemeMode(ThemeMode.light),
                    onRight: () => ref.read(themeModeControllerProvider.notifier).setThemeMode(ThemeMode.dark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(Icons.lock_outline_rounded, color: colors.primary),
                title: Text(l10n.changePassword),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _changePassword(context, ref),
              ),
            ),
          ],
        ),
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

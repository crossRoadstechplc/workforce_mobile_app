import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../auth/application/session_controller.dart';
import '../../notifications/application/notification_controller.dart';
import '../application/profile_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

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
    if (next.text.length < 10 ||
        next.text != confirm.text ||
        !RegExp(r'[A-Z]').hasMatch(next.text) ||
        !RegExp(r'[a-z]').hasMatch(next.text) ||
        !RegExp(r'[0-9]').hasMatch(next.text)) {
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
    final profile = ref.watch(profileControllerProvider);
    final l10n = context.l10n;
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(
          message: e.toString(),
          onRetry: () => ref.read(profileControllerProvider.notifier).refresh(),
        ),
        data: (user) => RefreshIndicator(
          onRefresh: () => ref.read(profileControllerProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: colors.primary.withValues(alpha: 0.10),
                      child: Text(
                        user.displayName.isNotEmpty
                            ? user.displayName.substring(0, 1).toUpperCase()
                            : (user.email.isEmpty ? 'E' : user.email.substring(0, 1).toUpperCase()),
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: colors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.displayName.isNotEmpty ? user.displayName : user.email,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 5),
                    Text(user.email, style: TextStyle(color: colors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(user.roles.join(' • '), style: TextStyle(color: colors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  children: [
                    _item(context, Icons.badge_outlined, l10n.accountId, user.id),
                    const Divider(),
                    _item(context, Icons.shield_outlined, l10n.role, user.roles.join(', ')),
                    const Divider(),
                    _item(context, Icons.lock_outline_rounded, l10n.access, l10n.permissionsCount(user.permissions.length)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.assignment_outlined, color: colors.primary),
                  title: Text(l10n.evaluationsTitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/evaluations'),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _changePassword(context, ref),
                icon: const Icon(Icons.password_rounded),
                label: Text(l10n.changePassword),
              ),
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: () async {
                  await ref.read(pushNotificationServiceProvider).unregister();
                  await ref.read(sessionControllerProvider.notifier).logout();
                },
                icon: const Icon(Icons.logout_rounded),
                label: Text(l10n.signOut),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _item(BuildContext context, IconData icon, String label, String value) {
  final colors = context.appColors;
  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: colors.primary),
    title: Text(label),
    subtitle: Text(value),
  );
}

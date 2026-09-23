import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../auth/application/session_controller.dart';
import '../../notifications/application/notification_controller.dart';
import '../application/profile_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);
    final l10n = context.l10n;
    final colors = context.appColors;

    return Scaffold(
      body: ResponsiveContent(
        child: profile.when(
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

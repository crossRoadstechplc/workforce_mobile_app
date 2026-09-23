import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../application/app_update_controller.dart';

class ForceUpdateOverlay extends ConsumerWidget {
  const ForceUpdateOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final update = ref.watch(appUpdateControllerProvider);
    final remote = update.remote?.androidVersion ?? '';

    return Material(
      color: Colors.black.withValues(alpha: 0.54),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                color: colors.surface,
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colors.warningBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.system_update_alt_rounded, color: colors.warning, size: 28),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.updateRequiredTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.updateRequiredBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.currentVersion(AppConfig.appVersion),
                        style: TextStyle(fontSize: 12, color: colors.textSecondary),
                      ),
                      if (remote.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          l10n.latestVersion(remote),
                          style: TextStyle(fontSize: 12, color: colors.textSecondary),
                        ),
                      ],
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () async {
                            final opened = await ref.read(appUpdateControllerProvider.notifier).openRelease();
                            if (!opened && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.updateOpenFailed)),
                              );
                            }
                          },
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: Text(l10n.updateNow),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.read(appUpdateControllerProvider.notifier).refresh(),
                        child: Text(l10n.tryAgain),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

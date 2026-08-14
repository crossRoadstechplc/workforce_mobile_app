import 'package:flutter/material.dart';

import '../localization/l10n_extensions.dart';
import '../theme/app_theme_extension.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
  });

  final String message;
  final VoidCallback? onRetry;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final normalized = message.toLowerCase();
    final looksOffline = normalized.contains('connection') ||
        normalized.contains('network') ||
        normalized.contains('socket') ||
        normalized.contains('timeout');
    final resolvedTitle = title ?? l10n.errorTitle;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Semantics(
          liveRegion: true,
          label: '$resolvedTitle. $message',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                looksOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                size: 42,
                color: looksOffline ? colors.warning : colors.error,
              ),
              const SizedBox(height: 12),
              Text(
                looksOffline ? l10n.connectionUnavailable : resolvedTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                looksOffline ? l10n.connectionRetryHint : message,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary, height: 1.4),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.tryAgain),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

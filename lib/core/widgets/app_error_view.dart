import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.title = 'Something went wrong',
  });

  final String message;
  final VoidCallback? onRetry;
  final String title;

  @override
  Widget build(BuildContext context) {
    final normalized = message.toLowerCase();
    final looksOffline = normalized.contains('connection') ||
        normalized.contains('network') ||
        normalized.contains('socket') ||
        normalized.contains('timeout');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Semantics(
          liveRegion: true,
          label: '$title. $message',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                looksOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                size: 42,
                color: looksOffline ? AppColors.warning : AppColors.error,
              ),
              const SizedBox(height: 12),
              Text(
                looksOffline ? 'Connection unavailable' : title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                looksOffline
                    ? 'Check your connection and try again. Your saved server data is not changed.'
                    : message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

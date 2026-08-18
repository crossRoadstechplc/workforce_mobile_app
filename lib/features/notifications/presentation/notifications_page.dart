import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:go_router/go_router.dart';
import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/app_error_view.dart';
import '../application/notification_controller.dart';
import '../data/notification_models.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationControllerProvider);
    final l10n = context.l10n;
    final colors = context.appColors;

    return Scaffold(
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(
          message: e.toString(),
          onRetry: () => ref.read(notificationControllerProvider.notifier).refresh(),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.read(notificationControllerProvider.notifier).refresh(),
          child: data.items.isEmpty
              ? ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 160),
                      child: Center(
                        child: Text(
                          l10n.noNotificationsYet,
                          style: TextStyle(color: colors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: data.items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _Tile(
                    item: data.items[i],
                    onTap: () {
                      final item = data.items[i];
                      ref.read(notificationControllerProvider.notifier).markRead(item.id);
                      if (item.relatedEntityType == 'Evaluation' && item.relatedEntityId != null) {
                        context.push('/evaluations/${item.relatedEntityId}');
                      }
                      if (item.relatedEntityType == 'MeetingBooking') {
                        context.go('/meetings');
                      }
                    },
                  ),
                ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.item, required this.onTap});

  final AppNotification item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locale = Localizations.localeOf(context).toString();

    return Material(
      color: item.isRead ? colors.surface : colors.primary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colors.primary.withValues(alpha: 0.10),
                child: Icon(_icon(item.type), color: colors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800),
                          ),
                        ),
                        Text(
                          DateFormat('MMM d', locale).format(item.createdAt),
                          style: TextStyle(color: colors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.message,
                      style: TextStyle(color: colors.textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),
              if (!item.isRead)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: CircleAvatar(radius: 4, backgroundColor: colors.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _icon(String type) => type.contains('EVALUATION')
    ? Icons.assignment_outlined
    : type.contains('LEAVE')
        ? Icons.beach_access_outlined
        : type.contains('CHECK') || type.contains('ATTENDANCE')
            ? Icons.schedule_rounded
            : Icons.notifications_none_rounded;

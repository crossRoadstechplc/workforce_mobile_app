import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/app_error_view.dart';
import '../application/chat_controller.dart';
import '../data/chat_models.dart';

class ChatListPage extends ConsumerWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(chatListControllerProvider);
    final l10n = context.l10n;
    final colors = context.appColors;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/chat/new'),
        icon: const Icon(Icons.chat_rounded),
        label: Text(l10n.newChat),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(
          message: e.toString(),
          onRetry: () => ref.read(chatListControllerProvider.notifier).refresh(),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.read(chatListControllerProvider.notifier).refresh(),
          child: data.items.isEmpty
              ? ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 140),
                      child: Column(
                        children: [
                          Icon(Icons.forum_outlined, size: 48, color: colors.textSecondary.withValues(alpha: 0.6)),
                          const SizedBox(height: 12),
                          Text(l10n.noChatsYet, style: TextStyle(color: colors.textSecondary)),
                          const SizedBox(height: 6),
                          Text(l10n.noChatsHint, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                  itemCount: data.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, i) => _ConversationTile(
                    item: data.items[i],
                    onTap: () => context.push('/chat/${data.items[i].id}'),
                  ),
                ),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.item, required this.onTap});

  final ChatConversation item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final unread = item.unreadCount > 0;
    final preview = item.lastMessage?.body ?? '';
    final time = item.lastMessage?.createdAt ?? item.updatedAt;

    return Material(
      color: unread ? colors.primary.withValues(alpha: 0.06) : colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colors.primary.withValues(alpha: 0.14),
                child: Text(
                  item.initial,
                  style: TextStyle(color: colors.primary, fontWeight: FontWeight.w800),
                ),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(context, time),
                          style: TextStyle(
                            color: unread ? colors.primary : colors.textSecondary,
                            fontSize: 12,
                            fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview.isEmpty ? context.l10n.noMessagesYet : preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(999)),
                            child: Text(
                              item.unreadCount > 99 ? '99+' : '${item.unreadCount}',
                              textAlign: TextAlign.center,
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
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatTime(BuildContext context, DateTime time) {
  final now = DateTime.now();
  final locale = Localizations.localeOf(context).toString();
  if (time.year == now.year && time.month == now.month && time.day == now.day) {
    return DateFormat.Hm(locale).format(time);
  }
  if (now.difference(time).inDays < 7) {
    return DateFormat.E(locale).format(time);
  }
  return DateFormat.MMMd(locale).format(time);
}

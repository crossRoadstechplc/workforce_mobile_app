import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../../l10n/app_localizations.dart';
import '../application/chat_controller.dart';
import '../data/chat_models.dart';

enum ChatTab { personal, group, admin }

class ChatListPage extends ConsumerStatefulWidget {
  const ChatListPage({super.key});

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage> {
  ChatTab _tab = ChatTab.personal;

  String get _typeFilter {
    switch (_tab) {
      case ChatTab.personal:
        return 'DIRECT';
      case ChatTab.group:
        return 'GROUP';
      case ChatTab.admin:
        return 'ADMIN';
    }
  }

  void _onFab() {
    if (_tab == ChatTab.group) {
      context.push('/chat/new-group');
      return;
    }
    if (_tab == ChatTab.admin) return;
    context.push('/chat/new');
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(chatListControllerProvider);
    final l10n = context.l10n;
    final colors = context.appColors;
    final showFab = _tab != ChatTab.admin;

    return Scaffold(
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              onPressed: _onFab,
              icon: Icon(_tab == ChatTab.group ? Icons.group_add_rounded : Icons.chat_rounded),
              label: Text(_tab == ChatTab.group ? l10n.newGroupChat : l10n.newChat),
            )
          : null,
      body: ResponsiveContent(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: SegmentedButton<ChatTab>(
                segments: [
                  ButtonSegment(value: ChatTab.personal, label: Text(l10n.chatTabPersonal), icon: const Icon(Icons.person_outline, size: 18)),
                  ButtonSegment(value: ChatTab.group, label: Text(l10n.chatTabGroup), icon: const Icon(Icons.groups_outlined, size: 18)),
                  ButtonSegment(value: ChatTab.admin, label: Text(l10n.chatTabAdmin), icon: const Icon(Icons.support_agent_outlined, size: 18)),
                ],
                selected: {_tab},
                onSelectionChanged: (next) => setState(() => _tab = next.first),
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  textStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.labelMedium),
                ),
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => AppErrorView(
                  message: e.toString(),
                  onRetry: () => ref.read(chatListControllerProvider.notifier).refresh(),
                ),
                data: (data) {
                  final items = data.items.where((c) => c.type == _typeFilter).toList();
                  return RefreshIndicator(
                    onRefresh: () => ref.read(chatListControllerProvider.notifier).refresh(),
                    child: items.isEmpty
                        ? ListView(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 120),
                                child: Column(
                                  children: [
                                    Icon(
                                      _tab == ChatTab.group
                                          ? Icons.groups_outlined
                                          : _tab == ChatTab.admin
                                              ? Icons.support_agent_outlined
                                              : Icons.forum_outlined,
                                      size: 48,
                                      color: colors.textSecondary.withValues(alpha: 0.6),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(_emptyTitle(l10n), style: TextStyle(color: colors.textSecondary)),
                                    const SizedBox(height: 6),
                                    Text(
                                      _emptyHint(l10n),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: colors.textSecondary, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 4),
                            itemBuilder: (context, i) => _ConversationTile(
                              item: items[i],
                              onTap: () => context.push('/chat/${items[i].id}'),
                            ),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _emptyTitle(AppLocalizations l10n) {
    switch (_tab) {
      case ChatTab.personal:
        return l10n.noChatsYet;
      case ChatTab.group:
        return l10n.noGroupChatsYet;
      case ChatTab.admin:
        return l10n.noAdminChatsYet;
    }
  }

  String _emptyHint(AppLocalizations l10n) {
    switch (_tab) {
      case ChatTab.personal:
        return l10n.noChatsHint;
      case ChatTab.group:
        return l10n.noGroupChatsHint;
      case ChatTab.admin:
        return l10n.noAdminChatsHint;
    }
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
                          DateFormat.jm().format(time),
                          style: TextStyle(fontSize: 11, color: colors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview.isEmpty ? '—' : preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: unread ? colors.textPrimary : colors.textSecondary,
                              fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              item.unreadCount > 99 ? '99+' : '${item.unreadCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
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

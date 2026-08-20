import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/realtime/socket_service.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../auth/application/session_controller.dart';
import '../../notifications/application/notification_controller.dart';
import '../application/chat_controller.dart';
import '../data/chat_models.dart';

class ChatThreadPage extends ConsumerStatefulWidget {
  const ChatThreadPage({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends ConsumerState<ChatThreadPage> {
  final _composer = TextEditingController();
  final _scroll = ScrollController();
  StreamSubscription<SocketEvent>? _subscription;
  ChatConversation? _conversation;
  List<ChatMessage> _messages = const [];
  bool _loading = true;
  bool _sending = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _subscription = ref.read(socketServiceProvider).events.listen(_onSocket);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _composer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(chatRepositoryProvider);
      final results = await Future.wait([
        repo.getConversation(widget.conversationId),
        repo.messages(widget.conversationId),
      ]);
      await repo.markRead(widget.conversationId);
      if (!mounted) return;
      setState(() {
        _conversation = results[0] as ChatConversation;
        _messages = results[1] as List<ChatMessage>;
        _loading = false;
      });
      _scrollToEnd();
      ref.invalidate(chatListControllerProvider);
      ref.invalidate(notificationControllerProvider);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _onSocket(SocketEvent event) {
    if (event.name != 'chat.message.created') return;
    final data = event.data;
    if (data is! Map) return;
    final conversationId = data['conversationId']?.toString();
    if (conversationId != widget.conversationId) return;
    final raw = data['message'];
    if (raw is! Map) return;
    final message = ChatMessage.fromJson(Map<String, dynamic>.from(raw));
    if (_messages.any((m) => m.id == message.id)) return;
    setState(() => _messages = [..._messages, message]);
    _scrollToEnd();
    ref.read(chatRepositoryProvider).markRead(widget.conversationId).catchError((_) {});
    ref.invalidate(chatListControllerProvider);
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  Future<void> _send() async {
    final text = _composer.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final message = await ref.read(chatRepositoryProvider).send(widget.conversationId, text);
      if (!mounted) return;
      _composer.clear();
      setState(() {
        _sending = false;
        if (!_messages.any((m) => m.id == message.id)) {
          _messages = [..._messages, message];
        }
      });
      _scrollToEnd();
      ref.invalidate(chatListControllerProvider);
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final myId = ref.watch(sessionControllerProvider.select((s) => s.user?.id));
    final title = _conversation?.title ?? l10n.navChat;
    final subtitle = _conversation?.peer?.subtitle;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colors.primary.withValues(alpha: 0.14),
              child: Text(
                _conversation?.initial ?? '?',
                style: TextStyle(color: colors.primary, fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  if (subtitle != null && subtitle.isNotEmpty)
                    Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? AppErrorView(message: _error.toString(), onRetry: _load)
              : Column(
                  children: [
                    Expanded(
                      child: _messages.isEmpty
                          ? Center(child: Text(l10n.sayHello, style: TextStyle(color: colors.textSecondary)))
                          : ListView.builder(
                              controller: _scroll,
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                              itemCount: _messages.length,
                              itemBuilder: (context, i) {
                                final message = _messages[i];
                                final mine = message.senderId == myId;
                                return _Bubble(message: message, mine: mine);
                              },
                            ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _composer,
                                minLines: 1,
                                maxLines: 5,
                                textCapitalization: TextCapitalization.sentences,
                                onSubmitted: (_) => _send(),
                                decoration: InputDecoration(
                                  hintText: l10n.messageHint,
                                  filled: true,
                                  fillColor: colors.muted,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              onPressed: _sending ? null : _send,
                              icon: _sending
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.send_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});

  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).toString();
    final bubbleColor = mine ? colors.primary : colors.surface;
    final textColor = mine
        ? (isDark ? const Color(0xFF0F172A) : Colors.white)
        : colors.textPrimary;
    final timeColor = mine
        ? textColor.withValues(alpha: 0.75)
        : colors.textSecondary;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(mine ? 16 : 4),
              bottomRight: Radius.circular(mine ? 4 : 16),
            ),
            border: mine ? null : Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!mine)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      message.senderName,
                      style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  message.body ?? '',
                  style: TextStyle(color: textColor, height: 1.35, fontSize: 15),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat.Hm(locale).format(message.createdAt),
                style: TextStyle(color: timeColor, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

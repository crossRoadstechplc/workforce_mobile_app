import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/app_error_view.dart';
import '../application/chat_controller.dart';
import '../data/chat_models.dart';

class NewChatPage extends ConsumerStatefulWidget {
  const NewChatPage({super.key});

  @override
  ConsumerState<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends ConsumerState<NewChatPage> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<ChatColleague> _items = const [];
  bool _loading = true;
  Object? _error;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load([String? query]) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await ref.read(chatRepositoryProvider).colleagues(query: query);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _onQuery(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () => _load(value));
  }

  Future<void> _open(ChatColleague colleague) async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final conversation = await ref.read(chatRepositoryProvider).openDirect(colleague.userId);
      if (!mounted) return;
      context.pushReplacement('/chat/${conversation.id}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _opening = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newChat),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: _onQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchColleagues,
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: colors.muted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_opening) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? AppErrorView(message: _error.toString(), onRetry: () => _load(_search.text))
                    : _items.isEmpty
                        ? Center(child: Text(l10n.noColleaguesFound, style: TextStyle(color: colors.textSecondary)))
                        : ListView.builder(
                            itemCount: _items.length,
                            itemBuilder: (context, i) {
                              final person = _items[i];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: colors.primary.withValues(alpha: 0.14),
                                  child: Text(person.initial, style: TextStyle(color: colors.primary, fontWeight: FontWeight.w800)),
                                ),
                                title: Text(person.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: person.subtitle.isEmpty ? null : Text(person.subtitle),
                                onTap: _opening ? null : () => _open(person),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

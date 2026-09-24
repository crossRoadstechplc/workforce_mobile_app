import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/app_error_view.dart';
import '../application/chat_controller.dart';
import '../data/chat_models.dart';

class NewGroupChatPage extends ConsumerStatefulWidget {
  const NewGroupChatPage({super.key});

  @override
  ConsumerState<NewGroupChatPage> createState() => _NewGroupChatPageState();
}

class _NewGroupChatPageState extends ConsumerState<NewGroupChatPage> {
  final _name = TextEditingController();
  final _search = TextEditingController();
  Timer? _debounce;
  List<ChatColleague> _items = const [];
  final Set<String> _selected = {};
  bool _loading = true;
  bool _creating = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _name.dispose();
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

  Future<void> _create() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.groupNameRequired)),
      );
      return;
    }
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.groupMembersRequired)),
      );
      return;
    }
    if (_creating) return;
    setState(() => _creating = true);
    try {
      final conversation = await ref.read(chatRepositoryProvider).createGroup(
            name: name,
            memberUserIds: _selected.toList(),
          );
      await ref.read(chatListControllerProvider.notifier).refresh();
      if (!mounted) return;
      context.pushReplacement('/chat/${conversation.id}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _creating = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newGroupChat),
        actions: [
          TextButton(
            onPressed: _creating ? null : _create,
            child: Text(l10n.createGroup),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.groupName,
                hintText: l10n.groupNameHint,
                filled: true,
                fillColor: colors.muted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
          if (_selected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.groupSelectedCount(_selected.length),
                  style: TextStyle(color: colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (_creating) const LinearProgressIndicator(minHeight: 2),
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
                              final selected = _selected.contains(person.userId);
                              return CheckboxListTile(
                                value: selected,
                                onChanged: (v) {
                                  setState(() {
                                    if (v == true) {
                                      _selected.add(person.userId);
                                    } else {
                                      _selected.remove(person.userId);
                                    }
                                  });
                                },
                                secondary: CircleAvatar(
                                  backgroundColor: colors.primary.withValues(alpha: 0.14),
                                  child: Text(person.initial, style: TextStyle(color: colors.primary, fontWeight: FontWeight.w800)),
                                ),
                                title: Text(person.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: person.subtitle.isEmpty ? null : Text(person.subtitle),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

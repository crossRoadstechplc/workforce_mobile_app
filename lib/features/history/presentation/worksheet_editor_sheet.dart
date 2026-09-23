import 'package:flutter/material.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';

Future<String?> showWorksheetEditorSheet(
  BuildContext context, {
  required String title,
  String? initialDescription,
  String? submitLabel,
}) {
  final colors = context.appColors;
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _WorksheetEditorSheet(
      title: title,
      initialDescription: initialDescription ?? '',
      submitLabel: submitLabel,
    ),
  );
}

class _WorksheetEditorSheet extends StatefulWidget {
  const _WorksheetEditorSheet({
    required this.title,
    required this.initialDescription,
    this.submitLabel,
  });

  final String title;
  final String initialDescription;
  final String? submitLabel;

  @override
  State<_WorksheetEditorSheet> createState() => _WorksheetEditorSheetState();
}

class _WorksheetEditorSheetState extends State<_WorksheetEditorSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialDescription);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Text(
            widget.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            minLines: 4,
            maxLines: 8,
            maxLength: 5000,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.workSummary,
              hintText: l10n.workSummaryHint,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _canSubmit ? () => Navigator.pop(context, _controller.text.trim()) : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    disabledBackgroundColor: colors.muted,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(widget.submitLabel ?? l10n.saveWorksheet),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

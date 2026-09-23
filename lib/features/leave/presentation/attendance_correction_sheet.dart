import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../history/history_date_utils.dart';

class AttendanceCorrectionDraft {
  const AttendanceCorrectionDraft({required this.dates, this.note});
  final List<String> dates;
  final String? note;
}

String dateToApiKey(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

Future<AttendanceCorrectionDraft?> showAttendanceCorrectionSheet(
  BuildContext context, {
  Set<String> blockedDateKeys = const {},
}) {
  return showModalBottomSheet<AttendanceCorrectionDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _AttendanceCorrectionSheet(blockedDateKeys: blockedDateKeys),
  );
}

class _AttendanceCorrectionSheet extends StatefulWidget {
  const _AttendanceCorrectionSheet({required this.blockedDateKeys});
  final Set<String> blockedDateKeys;

  @override
  State<_AttendanceCorrectionSheet> createState() => _AttendanceCorrectionSheetState();
}

class _AttendanceCorrectionSheetState extends State<_AttendanceCorrectionSheet> {
  final _note = TextEditingController();
  final _selectedDates = <String>{};

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  DateTime get _today => normalizeDate(DateTime.now());

  DateTime get _lastSelectable => _today.subtract(const Duration(days: 1));

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastSelectable,
      firstDate: DateTime(_lastSelectable.year - 1, _lastSelectable.month, _lastSelectable.day),
      lastDate: _lastSelectable,
    );
    if (picked == null) return;
    final key = dateToApiKey(normalizeDate(picked));
    if (widget.blockedDateKeys.contains(key)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.attendanceCorrectionDateBlocked)));
      }
      return;
    }
    setState(() => _selectedDates.add(key));
  }

  void _submit() {
    if (_selectedDates.isEmpty) return;
    final dates = _selectedDates.toList()..sort();
    Navigator.of(context).pop(
      AttendanceCorrectionDraft(
        dates: dates,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final locale = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMd(locale);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: colors.muted, borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.attendanceCorrectionTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(l10n.attendanceCorrectionHint, style: TextStyle(color: colors.textSecondary, height: 1.4)),
            const SizedBox(height: 16),
            TextField(
              controller: _note,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.attendanceCorrectionNoteLabel,
                hintText: l10n.attendanceCorrectionNoteHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(l10n.attendanceCorrectionDatesLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                TextButton.icon(onPressed: _pickDate, icon: const Icon(Icons.add_rounded), label: Text(l10n.attendanceCorrectionAddDate)),
              ],
            ),
            if (_selectedDates.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(l10n.attendanceCorrectionPickDate, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final key in (_selectedDates.toList()..sort()))
                    InputChip(
                      label: Text(dateFmt.format(parseCalendarDate(key))),
                      onDeleted: () => setState(() => _selectedDates.remove(key)),
                    ),
                ],
              ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _selectedDates.isEmpty ? null : _submit, child: Text(l10n.attendanceCorrectionSubmit)),
          ],
        ),
      ),
    );
  }
}

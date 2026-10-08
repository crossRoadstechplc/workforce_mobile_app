import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../l10n/app_localizations.dart';
import '../../history/history_date_utils.dart';
import '../data/leave_models.dart';
import 'leave_request_sheet.dart';

class AttendanceCorrectionDayDraft {
  const AttendanceCorrectionDayDraft({required this.date, required this.session});
  final String date;
  final LeaveDaySession session;

  Map<String, dynamic> toJson() => {'date': date, 'session': session.apiValue};
}

class AttendanceCorrectionDraft {
  const AttendanceCorrectionDraft({required this.days, this.note});
  final List<AttendanceCorrectionDayDraft> days;
  final String? note;

  List<String> get dates => days.map((d) => d.date).toList();
}

Future<AttendanceCorrectionDraft?> showAttendanceCorrectionSheet(
  BuildContext context, {
  Set<String> blockedDateKeys = const {},
  String? initialDate,
  List<String> initialDates = const [],
}) {
  return showModalBottomSheet<AttendanceCorrectionDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _AttendanceCorrectionSheet(
      blockedDateKeys: blockedDateKeys,
      initialDates: {
        ...initialDates,
        if (initialDate != null) initialDate,
      }.toList(),
    ),
  );
}

class _AttendanceCorrectionSheet extends StatefulWidget {
  const _AttendanceCorrectionSheet({required this.blockedDateKeys, this.initialDates = const []});
  final Set<String> blockedDateKeys;
  final List<String> initialDates;

  @override
  State<_AttendanceCorrectionSheet> createState() => _AttendanceCorrectionSheetState();
}

class _AttendanceCorrectionSheetState extends State<_AttendanceCorrectionSheet> {
  final _note = TextEditingController();
  final _sessions = <String, LeaveDaySession>{};

  @override
  void initState() {
    super.initState();
    for (final date in widget.initialDates) {
      if (!widget.blockedDateKeys.contains(date)) {
        _sessions[date] = LeaveDaySession.full;
      }
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  DateTime get _today => normalizeDate(DateTime.now());

  DateTime get _lastSelectable => _today.subtract(const Duration(days: 1));

  List<String> get _sortedDates {
    final keys = _sessions.keys.toList()..sort();
    return keys;
  }

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
    setState(() => _sessions.putIfAbsent(key, () => LeaveDaySession.full));
  }

  void _setAll(LeaveDaySession session) {
    setState(() {
      for (final key in _sessions.keys.toList()) {
        _sessions[key] = session;
      }
    });
  }

  void _submit() {
    if (_sessions.isEmpty) return;
    final days = _sortedDates
        .map((date) => AttendanceCorrectionDayDraft(date: date, session: _sessions[date] ?? LeaveDaySession.full))
        .toList();
    Navigator.of(context).pop(
      AttendanceCorrectionDraft(
        days: days,
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
            if (_sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(l10n.attendanceCorrectionPickDate, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
              )
            else ...[
              const SizedBox(height: 8),
              Text(l10n.leaveDaySessionsHint, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(label: Text(l10n.leaveSessionFull), onPressed: () => _setAll(LeaveDaySession.full)),
                  ActionChip(label: Text(l10n.leaveSessionMorning), onPressed: () => _setAll(LeaveDaySession.morning)),
                  ActionChip(label: Text(l10n.leaveSessionAfternoon), onPressed: () => _setAll(LeaveDaySession.afternoon)),
                ],
              ),
              const SizedBox(height: 12),
              for (final key in _sortedDates)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                    decoration: BoxDecoration(color: colors.muted, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(dateFmt.format(parseCalendarDate(key)), style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<LeaveDaySession>(
                            value: _sessions[key] ?? LeaveDaySession.full,
                            borderRadius: BorderRadius.circular(12),
                            items: [
                              DropdownMenuItem(value: LeaveDaySession.full, child: Text(l10n.leaveSessionFull)),
                              DropdownMenuItem(value: LeaveDaySession.morning, child: Text(l10n.leaveSessionMorning)),
                              DropdownMenuItem(value: LeaveDaySession.afternoon, child: Text(l10n.leaveSessionAfternoon)),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _sessions[key] = v);
                            },
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => setState(() => _sessions.remove(key)),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 24),
            FilledButton(onPressed: _sessions.isEmpty ? null : _submit, child: Text(l10n.attendanceCorrectionSubmit)),
          ],
        ),
      ),
    );
  }
}

String dateToApiKey(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

String correctionSessionLabel(AppLocalizations l10n, LeaveDaySession session) => leaveSessionLabel(l10n, session);

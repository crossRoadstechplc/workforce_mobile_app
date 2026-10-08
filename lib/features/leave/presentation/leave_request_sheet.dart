import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../l10n/app_localizations.dart';
import '../data/leave_models.dart';

class LeaveDraft {
  const LeaveDraft({
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.days,
  });
  final String leaveTypeId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final List<LeaveDayDraft> days;
}

Future<LeaveDraft?> showLeaveRequestSheet(
  BuildContext context,
  List<LeaveType> types, {
  AnnualLeaveBalance? balance,
}) {
  return showModalBottomSheet<LeaveDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _LeaveRequestSheet(types: types, balance: balance),
  );
}

class _LeaveRequestSheet extends StatefulWidget {
  const _LeaveRequestSheet({required this.types, this.balance});
  final List<LeaveType> types;
  final AnnualLeaveBalance? balance;
  @override
  State<_LeaveRequestSheet> createState() => _State();
}

class _State extends State<_LeaveRequestSheet> {
  String? typeId;
  DateTime? start;
  DateTime? end;
  final reason = TextEditingController();
  final Map<String, LeaveDaySession> _sessions = {};

  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  LeaveType? get selectedType {
    if (typeId == null) return null;
    for (final type in widget.types) {
      if (type.id == typeId) return type;
    }
    return null;
  }

  List<DateTime> get _rangeDays {
    if (start == null || end == null || end!.isBefore(start!)) return const [];
    final days = <DateTime>[];
    var cur = DateTime(start!.year, start!.month, start!.day);
    final last = DateTime(end!.year, end!.month, end!.day);
    while (!cur.isAfter(last)) {
      days.add(cur);
      cur = cur.add(const Duration(days: 1));
    }
    return days;
  }

  String _key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  LeaveDaySession _sessionFor(DateTime d) => _sessions[_key(d)] ?? LeaveDaySession.full;

  void _setSession(DateTime d, LeaveDaySession session) {
    setState(() => _sessions[_key(d)] = session);
  }

  void _setAll(LeaveDaySession session) {
    setState(() {
      for (final d in _rangeDays) {
        _sessions[_key(d)] = session;
      }
    });
  }

  double get _estimatedDays {
    var total = 0.0;
    for (final d in _rangeDays) {
      total += _sessionFor(d).dayMultiplier;
    }
    return total;
  }

  Future<void> pick(bool isStart) async {
    final now = DateTime.now();
    final first = DateTime(now.year - 1, now.month, now.day);
    final last = DateTime(now.year + 2);
    final initial = isStart ? (start ?? now) : (end ?? start ?? now);
    final value = await showDatePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDate: initial.isBefore(first) ? first : initial,
    );
    if (value != null) {
      setState(() {
        if (isStart) {
          start = value;
          if (end != null && end!.isBefore(value)) end = value;
        } else {
          end = value;
        }
        final keys = _rangeDays.map(_key).toSet();
        _sessions.removeWhere((k, _) => !keys.contains(k));
        for (final d in _rangeDays) {
          _sessions.putIfAbsent(_key(d), () => LeaveDaySession.full);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tracksBalance = selectedType?.tracksBalance == true;
    final available = widget.balance?.available;
    final rangeDays = _rangeDays;
    final valid = typeId != null && start != null && end != null && !end!.isBefore(start!) && reason.text.trim().length >= 5;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.requestLeave, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: typeId,
              decoration: InputDecoration(labelText: l10n.leaveTypeLabel),
              items: widget.types.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
              onChanged: (v) => setState(() => typeId = v),
            ),
            const SizedBox(height: 12),
            if (tracksBalance && available != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.appColors.muted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.annualLeaveAvailableHint(formatLeaveDays(available)),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => pick(true),
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(start == null ? l10n.leaveStartDate : DateFormat('MMM d, yyyy').format(start!)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => pick(false),
                    icon: const Icon(Icons.event_outlined),
                    label: Text(end == null ? l10n.leaveEndDate : DateFormat('MMM d, yyyy').format(end!)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.leavePastDatesHint, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)),
            if (rangeDays.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(l10n.leaveDaySessionsTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                l10n.leaveDaySessionsHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _BulkChip(label: l10n.leaveSessionFull, onTap: () => _setAll(LeaveDaySession.full)),
                  _BulkChip(label: l10n.leaveSessionMorning, onTap: () => _setAll(LeaveDaySession.morning)),
                  _BulkChip(label: l10n.leaveSessionAfternoon, onTap: () => _setAll(LeaveDaySession.afternoon)),
                ],
              ),
              const SizedBox(height: 12),
              ...rangeDays.map((d) {
                final session = _sessionFor(d);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                    decoration: BoxDecoration(
                      color: context.appColors.muted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat('EEE, MMM d').format(d),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<LeaveDaySession>(
                            value: session,
                            borderRadius: BorderRadius.circular(12),
                            items: [
                              DropdownMenuItem(value: LeaveDaySession.full, child: Text(l10n.leaveSessionFull)),
                              DropdownMenuItem(value: LeaveDaySession.morning, child: Text(l10n.leaveSessionMorning)),
                              DropdownMenuItem(value: LeaveDaySession.afternoon, child: Text(l10n.leaveSessionAfternoon)),
                            ],
                            onChanged: (v) {
                              if (v != null) _setSession(d, v);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              Text(
                l10n.leaveEstimatedDays(formatLeaveDays(_estimatedDays)),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: reason,
              minLines: 3,
              maxLines: 6,
              maxLength: 2000,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: l10n.leaveReason, hintText: l10n.leaveReasonHint),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: valid
                  ? () => Navigator.pop(
                        context,
                        LeaveDraft(
                          leaveTypeId: typeId!,
                          startDate: start!,
                          endDate: end!,
                          reason: reason.text.trim(),
                          days: rangeDays
                              .map((d) => LeaveDayDraft(date: d, session: _sessionFor(d)))
                              .toList(),
                        ),
                      )
                  : null,
              child: Text(l10n.submitLeaveRequest),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulkChip extends StatelessWidget {
  const _BulkChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}

String leaveSessionLabel(AppLocalizations l10n, LeaveDaySession session) => switch (session) {
      LeaveDaySession.full => l10n.leaveSessionFull,
      LeaveDaySession.morning => l10n.leaveSessionMorning,
      LeaveDaySession.afternoon => l10n.leaveSessionAfternoon,
    };

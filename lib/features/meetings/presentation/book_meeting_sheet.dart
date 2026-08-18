import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/l10n_extensions.dart';
import '../data/meeting_models.dart';

class MeetingDraft {
  const MeetingDraft({
    required this.roomId,
    required this.title,
    required this.startsAt,
    required this.endsAt,
    this.notes,
  });
  final String roomId;
  final String title;
  final DateTime startsAt;
  final DateTime endsAt;
  final String? notes;
}

Future<MeetingDraft?> showBookMeetingSheet(
  BuildContext context,
  List<MeetingRoom> rooms,
  Future<List<MeetingBusySlot>> Function(String roomId, DateTime date) loadBusy,
) {
  return showModalBottomSheet<MeetingDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _BookSheet(rooms: rooms, loadBusy: loadBusy),
  );
}

class _BookSheet extends StatefulWidget {
  const _BookSheet({required this.rooms, required this.loadBusy});
  final List<MeetingRoom> rooms;
  final Future<List<MeetingBusySlot>> Function(String roomId, DateTime date) loadBusy;
  @override
  State<_BookSheet> createState() => _BookSheetState();
}

class _BookSheetState extends State<_BookSheet> {
  String? roomId;
  DateTime date = DateTime.now();
  TimeOfDay start = TimeOfDay(hour: (TimeOfDay.now().hour + 1) % 24, minute: 0);
  TimeOfDay end = TimeOfDay(hour: (TimeOfDay.now().hour + 2) % 24, minute: 0);
  final title = TextEditingController();
  final notes = TextEditingController();
  List<MeetingBusySlot> busy = const [];
  bool loadingBusy = false;

  @override
  void dispose() {
    title.dispose();
    notes.dispose();
    super.dispose();
  }

  DateTime _combine(TimeOfDay t) => DateTime(date.year, date.month, date.day, t.hour, t.minute);

  Future<void> _loadBusy() async {
    if (roomId == null) return;
    setState(() => loadingBusy = true);
    try {
      final slots = await widget.loadBusy(roomId!, date);
      if (mounted) setState(() => busy = slots);
    } catch (_) {
      if (mounted) setState(() => busy = const []);
    } finally {
      if (mounted) setState(() => loadingBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = DateFormat.jm(Localizations.localeOf(context).toString());
    final startsAt = _combine(start);
    final endsAt = _combine(end);
    final valid = roomId != null && title.text.trim().length >= 2 && endsAt.isAfter(startsAt);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.bookMeeting, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: InputDecoration(labelText: l10n.meetingRoom),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: roomId,
                  hint: Text(l10n.pickRoom),
                  items: widget.rooms
                      .map((r) => DropdownMenuItem(value: r.id, child: Text('${r.name} · ${r.officeName}')))
                      .toList(),
                  onChanged: (v) {
                    setState(() => roomId = v);
                    _loadBusy();
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                  initialDate: date,
                );
                if (picked != null) {
                  setState(() => date = picked);
                  _loadBusy();
                }
              },
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(DateFormat.yMMMd().format(date)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final picked = await showTimePicker(context: context, initialTime: start);
                      if (picked != null) setState(() => start = picked);
                    },
                    child: Text('${l10n.meetingStart}: ${start.format(context)}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final picked = await showTimePicker(context: context, initialTime: end);
                      if (picked != null) setState(() => end = picked);
                    },
                    child: Text('${l10n.meetingEnd}: ${end.format(context)}'),
                  ),
                ),
              ],
            ),
            if (loadingBusy) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
            if (busy.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(l10n.meetingBusy, style: const TextStyle(fontWeight: FontWeight.w700)),
              ...busy.map(
                (s) => Text(
                  '${fmt.format(s.startsAt)} – ${fmt.format(s.endsAt)}${s.mine ? ' · ${s.title}' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: title,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: l10n.meetingTitle),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notes,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(labelText: l10n.meetingNotes),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: valid
                  ? () => Navigator.pop(
                        context,
                        MeetingDraft(roomId: roomId!, title: title.text.trim(), startsAt: startsAt, endsAt: endsAt, notes: notes.text),
                      )
                  : null,
              child: Text(l10n.bookMeeting),
            ),
          ],
        ),
      ),
    );
  }
}

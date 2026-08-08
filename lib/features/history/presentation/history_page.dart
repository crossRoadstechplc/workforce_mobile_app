import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/status_chip.dart';
import '../application/history_controller.dart';
import '../data/history_models.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});
  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  DateTime _selectedDay = DateTime.now();
  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        bottom: TabBar(controller: _tab, tabs: const [Tab(text: 'Timesheet'), Tab(text: 'Worksheet')]),
      ),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(message: e.toString(), onRetry: () => ref.read(historyControllerProvider.notifier).refresh()),
        data: (data) => TabBarView(controller: _tab, children: [
          _TimesheetCalendar(data: data, selectedDay: _selectedDay, onSelected: (day) => setState(() => _selectedDay = day)),
          _WorksheetCalendar(data: data, selectedDay: _selectedDay, onSelected: (day) => setState(() => _selectedDay = day)),
        ]),
      ),
    );
  }
}

class _TimesheetCalendar extends ConsumerWidget {
  const _TimesheetCalendar({required this.data, required this.selectedDay, required this.onSelected});
  final HistoryState data;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = data.timesheets.where((e) => isSameDay(e.workDate, selectedDay)).firstOrNull;
    return RefreshIndicator(
      onRefresh: () => ref.read(historyControllerProvider.notifier).refresh(),
      child: ListView(padding: const EdgeInsets.all(16), children: [
        AppCard(child: TableCalendar<TimesheetHistoryItem>(
          firstDay: DateTime(2020), lastDay: DateTime(2035), focusedDay: data.month,
          selectedDayPredicate: (day) => isSameDay(day, selectedDay),
          eventLoader: (day) => data.timesheets.where((e) => isSameDay(e.workDate, day)).toList(),
          onDaySelected: (selected, _) => onSelected(selected),
          onPageChanged: (month) => ref.read(historyControllerProvider.notifier).changeMonth(month),
          calendarFormat: CalendarFormat.month,
          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
          calendarStyle: const CalendarStyle(markerDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
        )),
        const SizedBox(height: 16),
        if (selected == null) const _EmptyDay(message: 'No timesheet for this day.') else FutureBuilder<TimesheetHistoryItem>(future: ref.read(historyRepositoryProvider).timesheet(selected.id), builder: (context, snap) => snap.hasData ? _TimesheetCard(item: snap.data!) : _TimesheetCard(item: selected)),
      ]),
    );
  }
}

class _WorksheetCalendar extends ConsumerWidget {
  const _WorksheetCalendar({required this.data, required this.selectedDay, required this.onSelected});
  final HistoryState data;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelected;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = data.worksheets.where((e) => isSameDay(e.workDate, selectedDay)).firstOrNull;
    return RefreshIndicator(
      onRefresh: () => ref.read(historyControllerProvider.notifier).refresh(),
      child: ListView(padding: const EdgeInsets.all(16), children: [
        AppCard(child: TableCalendar<WorksheetHistoryItem>(
          firstDay: DateTime(2020), lastDay: DateTime(2035), focusedDay: data.month,
          selectedDayPredicate: (day) => isSameDay(day, selectedDay),
          eventLoader: (day) => data.worksheets.where((e) => isSameDay(e.workDate, day)).toList(),
          onDaySelected: (selected, _) => onSelected(selected),
          onPageChanged: (month) => ref.read(historyControllerProvider.notifier).changeMonth(month),
          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
          calendarStyle: const CalendarStyle(markerDecoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
        )),
        const SizedBox(height: 16),
        if (selected == null) const _EmptyDay(message: 'No worksheet for this day.') else FutureBuilder<WorksheetHistoryItem>(future: ref.read(historyRepositoryProvider).worksheet(selected.id), builder: (context, snap) => snap.hasData ? _WorksheetCard(item: snap.data!) : _WorksheetCard(item: selected)),
      ]),
    );
  }
}

class _TimesheetCard extends StatelessWidget {
  const _TimesheetCard({required this.item}); final TimesheetHistoryItem item;
  @override
  Widget build(BuildContext context) => AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Expanded(child: Text(DateFormat('EEEE, MMM d').format(item.workDate), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))), StatusChip(label: _statusLabel(item), kind: item.isMissingCheckout ? StatusKind.error : item.isLate ? StatusKind.warning : StatusKind.success)]),
    const SizedBox(height: 16),
    _row('Check-in', item.actualCheckIn == null ? '—' : DateFormat('HH:mm').format(item.actualCheckIn!)),
    _row('Check-out', item.actualCheckOut == null ? '—' : DateFormat('HH:mm').format(item.actualCheckOut!)),
    _row('Worked', _duration(item.workedMinutes)),
    _row('Late', '${item.lateMinutes} min'),
    if (item.earlyCheckoutMinutes > 0) _row('Early checkout', '${item.earlyCheckoutMinutes} min'),
    if (item.overtimeMinutes > 0) _row('Overtime', '${item.overtimeMinutes} min'),
  ]));
}

class _WorksheetCard extends StatelessWidget {
  const _WorksheetCard({required this.item}); final WorksheetHistoryItem item;
  @override
  Widget build(BuildContext context) => AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Expanded(child: Text(DateFormat('EEEE, MMM d').format(item.workDate), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))), const StatusChip(label: 'Submitted', kind: StatusKind.success)]),
    const SizedBox(height: 14), Text(item.description.isEmpty ? 'Worksheet submitted.' : item.description, style: const TextStyle(height: 1.5)),
    if (item.workedMinutes > 0) ...[const SizedBox(height: 14), Text('Worked ${_duration(item.workedMinutes)}', style: const TextStyle(color: AppColors.textSecondary))],
  ]));
}

class _EmptyDay extends StatelessWidget { const _EmptyDay({required this.message}); final String message; @override Widget build(BuildContext context) => AppCard(child: Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Center(child: Text(message, style: const TextStyle(color: AppColors.textSecondary))))); }
Widget _row(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary))), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))]));
String _duration(int minutes) => '${minutes ~/ 60}h ${minutes % 60}m';
String _statusLabel(TimesheetHistoryItem i) => i.isMissingCheckout ? 'Missing checkout' : i.isLate ? 'Late' : 'On time';

extension _FirstOrNull<E> on Iterable<E> { E? get firstOrNull { final it = iterator; return it.moveNext() ? it.current : null; } }

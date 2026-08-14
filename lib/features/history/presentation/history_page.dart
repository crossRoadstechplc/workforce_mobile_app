import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/status_chip.dart';
import '../application/history_controller.dart';
import '../data/history_models.dart';
import '../history_date_utils.dart';
import 'day_strip_picker.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});
  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _selectedDay = normalizeDate(DateTime.now());
    _tab.addListener(() {
      if (!_tab.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyControllerProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        bottom: TabBar(
          controller: _tab,
          tabs: [
            Tab(text: l10n.tabTimesheet),
            Tab(text: l10n.tabWorksheet),
          ],
        ),
      ),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(
          message: e.toString(),
          onRetry: () => ref.read(historyControllerProvider.notifier).refresh(),
        ),
        data: (data) => Column(
          children: [
            DayStripPicker(
              monthKeys: data.loadedMonthKeys.toList(),
              selected: _selectedDay,
              visibleMonth: data.visibleMonth,
              onSelected: (day) => setState(() => _selectedDay = normalizeDate(day)),
              onVisibleMonthChanged: (month) {
                ref.read(historyControllerProvider.notifier).onVisibleMonthChanged(month);
              },
              onPrefetchEarlier: (month) {
                ref.read(historyControllerProvider.notifier).prefetchEarlier(month);
              },
              hasData: _tab.index == 0
                  ? (day) => data.timesheets.any((e) => isSameCalendarDay(e.workDate, day))
                  : (day) => data.worksheets.any((e) => isSameCalendarDay(e.workDate, day)),
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _TimesheetDayView(data: data, selectedDay: _selectedDay),
                  _WorksheetDayView(data: data, selectedDay: _selectedDay),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimesheetDayView extends ConsumerWidget {
  const _TimesheetDayView({required this.data, required this.selectedDay});
  final HistoryState data;
  final DateTime selectedDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final selected = data.timesheets.where((e) => isSameCalendarDay(e.workDate, selectedDay)).firstOrNull;

    return RefreshIndicator(
      onRefresh: () => ref.read(historyControllerProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            DateFormat('EEEE, MMMM d', locale).format(selectedDay),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.appColors.textSecondary),
          ),
          const SizedBox(height: 12),
          if (selected == null)
            _EmptyDay(message: l10n.noTimesheetDay)
          else
            FutureBuilder<TimesheetHistoryItem>(
              future: ref.read(historyRepositoryProvider).timesheet(selected.id),
              builder: (context, snap) => snap.hasData ? _TimesheetCard(item: snap.data!) : _TimesheetCard(item: selected),
            ),
        ],
      ),
    );
  }
}

class _WorksheetDayView extends ConsumerWidget {
  const _WorksheetDayView({required this.data, required this.selectedDay});
  final HistoryState data;
  final DateTime selectedDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final selected = data.worksheets.where((e) => isSameCalendarDay(e.workDate, selectedDay)).firstOrNull;

    return RefreshIndicator(
      onRefresh: () => ref.read(historyControllerProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            DateFormat('EEEE, MMMM d', locale).format(selectedDay),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.appColors.textSecondary),
          ),
          const SizedBox(height: 12),
          if (selected == null)
            _EmptyDay(message: l10n.noWorksheetDay)
          else
            FutureBuilder<WorksheetHistoryItem>(
              future: ref.read(historyRepositoryProvider).worksheet(selected.id),
              builder: (context, snap) => snap.hasData ? _WorksheetCard(item: snap.data!) : _WorksheetCard(item: selected),
            ),
        ],
      ),
    );
  }
}

class _TimesheetCard extends StatelessWidget {
  const _TimesheetCard({required this.item});
  final TimesheetHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('EEEE, MMM d', locale).format(item.workDate),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              StatusChip(
                label: _statusLabel(context, item),
                kind: item.isMissingCheckout ? StatusKind.error : item.isLate ? StatusKind.warning : StatusKind.success,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _row(context, l10n.checkInLabel, item.actualCheckIn == null ? l10n.dash : DateFormat('HH:mm', locale).format(item.actualCheckIn!)),
          _row(context, l10n.checkOutLabel, item.actualCheckOut == null ? l10n.dash : DateFormat('HH:mm', locale).format(item.actualCheckOut!)),
          _row(context, l10n.worked, formatDurationMinutes(context, item.workedMinutes)),
          _row(context, l10n.lateMinutes, l10n.lateMinutesValue(item.lateMinutes)),
          if (item.earlyCheckoutMinutes > 0) _row(context, l10n.earlyCheckout, l10n.earlyCheckoutMinutes(item.earlyCheckoutMinutes)),
          if (item.overtimeMinutes > 0) _row(context, l10n.overtime, l10n.overtimeMinutes(item.overtimeMinutes)),
        ],
      ),
    );
  }
}

class _WorksheetCard extends StatelessWidget {
  const _WorksheetCard({required this.item});
  final WorksheetHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('EEEE, MMM d', locale).format(item.workDate),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              StatusChip(label: l10n.submitted, kind: StatusKind.success),
            ],
          ),
          const SizedBox(height: 14),
          Text(item.description.isEmpty ? l10n.worksheetSubmitted : item.description, style: const TextStyle(height: 1.5)),
          if (item.workedMinutes > 0) ...[
            const SizedBox(height: 14),
            Text(
              l10n.workedDuration(formatDurationMinutes(context, item.workedMinutes)),
              style: TextStyle(color: context.appColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => AppCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(message, style: TextStyle(color: context.appColors.textSecondary)),
          ),
        ),
      );
}

Widget _row(BuildContext context, String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: context.appColors.textSecondary))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );

String _statusLabel(BuildContext context, TimesheetHistoryItem i) {
  final l10n = context.l10n;
  if (i.isMissingCheckout) return l10n.missingCheckout;
  if (i.isLate) return l10n.late;
  return l10n.onTime;
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../../core/widgets/status_chip.dart';
import '../application/history_controller.dart';
import '../data/history_models.dart';
import '../history_date_utils.dart';
import 'day_strip_picker.dart';
import 'worksheet_actions.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});
  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late DateTime _selectedDay;
  bool _didAutoPickWorksheetDay = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _selectedDay = normalizeDate(DateTime.now());
    _tab.addListener(() {
      if (!_tab.indexIsChanging) {
        setState(() {});
        if (_tab.index == 1) {
          _preferWorksheetActionDay();
        }
      }
    });
  }

  void _preferWorksheetActionDay([HistoryState? data]) {
    final history = data ?? ref.read(historyControllerProvider).value;
    if (history == null) return;

    final onSelected = history.timesheets.any((e) => isSameCalendarDay(e.workDate, _selectedDay)) ||
        history.worksheets.any((e) => isSameCalendarDay(e.workDate, _selectedDay));
    if (onSelected) return;

    final missing = history.timesheets.where((e) => e.canAddWorksheet).toList()
      ..sort((a, b) => b.workDate.compareTo(a.workDate));
    if (missing.isNotEmpty) {
      setState(() => _selectedDay = normalizeDate(missing.first.workDate));
      return;
    }

    final withSheet = [...history.worksheets]..sort((a, b) => b.workDate.compareTo(a.workDate));
    if (withSheet.isNotEmpty) {
      setState(() => _selectedDay = normalizeDate(withSheet.first.workDate));
      return;
    }

    final closed = history.timesheets.where((e) => e.isClosed).toList()
      ..sort((a, b) => b.workDate.compareTo(a.workDate));
    if (closed.isNotEmpty) {
      setState(() => _selectedDay = normalizeDate(closed.first.workDate));
    }
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
    final colors = context.appColors;

    return Scaffold(
      body: ResponsiveContent(
        maxWidth: 960,
        child: Column(
        children: [
          Material(
            color: colors.background,
            child: TabBar(
              controller: _tab,
              tabs: [
                Tab(text: l10n.tabTimesheet),
                Tab(text: l10n.tabWorksheet),
              ],
            ),
          ),
          Expanded(
            child: history.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppErrorView(
                message: e.toString(),
                onRetry: () => ref.read(historyControllerProvider.notifier).refresh(),
              ),
              data: (data) {
                if (_tab.index == 1 && !_didAutoPickWorksheetDay) {
                  _didAutoPickWorksheetDay = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) => _preferWorksheetActionDay(data));
                }
                return Column(
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
                        : (day) =>
                            data.worksheets.any((e) => isSameCalendarDay(e.workDate, day)) ||
                            data.timesheets.any((e) => isSameCalendarDay(e.workDate, day) && e.hasCheckedIn),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tab,
                      children: [
                        _TimesheetDayView(data: data, selectedDay: _selectedDay),
                        _WorksheetDayView(
                          data: data,
                          selectedDay: _selectedDay,
                          onSelectDay: (day) => setState(() => _selectedDay = normalizeDate(day)),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _TimesheetDayView extends ConsumerStatefulWidget {
  const _TimesheetDayView({required this.data, required this.selectedDay});
  final HistoryState data;
  final DateTime selectedDay;

  @override
  ConsumerState<_TimesheetDayView> createState() => _TimesheetDayViewState();
}

class _TimesheetDayViewState extends ConsumerState<_TimesheetDayView> {
  final Set<DateTime> _requestDates = {};
  bool _pickingDates = false;

  String _dateKey(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  bool _canRequest(DateTime day) {
    final today = normalizeDate(DateTime.now());
    if (!day.isBefore(today)) return false;
    final status = widget.data.correctnessForDay(day);
    if (status != null && status != 'REJECTED') return false;
    final sheet = widget.data.timesheets.where((e) => isSameCalendarDay(e.workDate, day)).firstOrNull;
    if (sheet != null &&
        sheet.actualCheckIn != null &&
        sheet.actualCheckOut != null &&
        !sheet.isMissingCheckout &&
        (sheet.status == 'COMPLETED_ON_TIME' || sheet.status == 'COMPLETED_LATE')) {
      return false;
    }
    return true;
  }

  Future<void> _submitRequests() async {
    final dates = (_pickingDates ? _requestDates : {normalizeDate(widget.selectedDay)})
        .where(_canRequest)
        .map(_dateKey)
        .toList();
    if (dates.isEmpty) return;
    try {
      await ref.read(historyControllerProvider.notifier).submitCorrectnessRequests(dates);
      if (mounted) {
        setState(() {
          _pickingDates = false;
          _requestDates.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.attendanceCorrectionSubmitted)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final selected = widget.data.timesheets.where((e) => isSameCalendarDay(e.workDate, widget.selectedDay)).firstOrNull;
    final correctness = widget.data.correctnessForDay(widget.selectedDay);
    final canRequest = _canRequest(normalizeDate(widget.selectedDay));

    return RefreshIndicator(
      onRefresh: () => ref.read(historyControllerProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            DateFormat('EEEE, MMMM d', locale).format(widget.selectedDay),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.appColors.textSecondary),
          ),
          const SizedBox(height: 12),
          if (correctness != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: StatusChip(
                label: correctness,
                kind: correctness == 'PENDING'
                    ? StatusKind.warning
                    : correctness == 'APPROVED'
                        ? StatusKind.success
                        : StatusKind.error,
              ),
            ),
          if (canRequest && (correctness == null || correctness == 'REJECTED')) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitRequests,
                    child: Text(l10n.requestAttendanceCorrection),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => setState(() {
                    _pickingDates = !_pickingDates;
                    _requestDates
                      ..clear()
                      ..add(normalizeDate(widget.selectedDay));
                  }),
                  child: Text(_pickingDates ? 'Done' : 'Multi-day'),
                ),
              ],
            ),
            if (_pickingDates) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.data.timesheets
                    .where((item) => _canRequest(normalizeDate(item.workDate)))
                    .map((item) {
                      final day = normalizeDate(item.workDate);
                      final selectedChip = _requestDates.contains(day);
                      return FilterChip(
                        label: Text(DateFormat('MMM d', locale).format(day)),
                        selected: selectedChip,
                        onSelected: (value) => setState(() {
                          if (value) {
                            _requestDates.add(day);
                          } else {
                            _requestDates.remove(day);
                          }
                        }),
                      );
                    })
                    .toList(),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _requestDates.isEmpty ? null : _submitRequests,
                  child: Text('Submit ${_requestDates.length} day(s)'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
          if (selected == null && !canRequest)
            _EmptyDay(message: l10n.noTimesheetDay)
          else if (selected == null)
            _EmptyDay(message: 'No attendance recorded for this day.')
          else
            FutureBuilder<TimesheetHistoryItem>(
              future: ref.read(historyRepositoryProvider).timesheet(selected.id),
              builder: (context, snap) =>
                  snap.hasData ? _TimesheetCard(item: snap.data!) : _TimesheetCard(item: selected),
            ),
        ],
      ),
    );
  }
}

class _WorksheetDayView extends ConsumerWidget {
  const _WorksheetDayView({
    required this.data,
    required this.selectedDay,
    required this.onSelectDay,
  });
  final HistoryState data;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelectDay;

  List<TimesheetHistoryItem> get _daysNeedingWorksheet {
    final worksheetDays = data.worksheets.map((e) => normalizeDate(e.workDate)).toSet();
    final items = data.timesheets.where((e) {
      if (!e.canAddWorksheet) return false;
      if (worksheetDays.contains(normalizeDate(e.workDate))) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.workDate.compareTo(a.workDate));
    return items;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final worksheet = data.worksheets.where((e) => isSameCalendarDay(e.workDate, selectedDay)).firstOrNull;
    final timesheet = data.timesheets.where((e) => isSameCalendarDay(e.workDate, selectedDay)).firstOrNull;
    final worksheetId = worksheet?.id ?? timesheet?.worksheetId;
    final needing = _daysNeedingWorksheet;

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
          if (timesheet != null) ...[
            _AttendanceSummaryCard(item: timesheet),
            const SizedBox(height: 12),
          ],
          if (worksheetId != null)
            FutureBuilder<WorksheetHistoryItem>(
              future: ref.read(historyRepositoryProvider).worksheet(worksheetId),
              builder: (context, snap) {
                final item = snap.data ??
                    worksheet ??
                    WorksheetHistoryItem(
                      id: worksheetId,
                      workDate: selectedDay,
                      status: 'SUBMITTED',
                      description: '',
                    );
                return _WorksheetCard(
                  item: item,
                  onEdit: () => editWorksheetItem(
                    context,
                    ref,
                    worksheetId: item.id,
                    initialDescription: item.description,
                  ),
                );
              },
            )
          else if (timesheet != null && timesheet.canAddWorksheet)
            AppCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.tabWorksheet,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.noWorksheetDay,
                      style: TextStyle(color: context.appColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => addWorksheetForTimesheet(context, ref, timesheet),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addWorksheet),
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            _EmptyDay(message: l10n.noWorksheetNeedAttendance),
            if (needing.isNotEmpty) ...[
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.daysNeedingWorksheet,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.tapDayToAddWorksheet,
                      style: TextStyle(color: context.appColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: needing.take(12).map((item) {
                        return ActionChip(
                          label: Text(DateFormat('EEE, MMM d', locale).format(item.workDate)),
                          onPressed: () => onSelectDay(item.workDate),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ] else if (data.worksheets.isNotEmpty) ...[
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.existingWorksheets,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.tapDayToEditWorksheet,
                      style: TextStyle(color: context.appColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ([...data.worksheets]..sort((a, b) => b.workDate.compareTo(a.workDate)))
                          .take(12)
                          .map((item) {
                        return ActionChip(
                          label: Text(DateFormat('EEE, MMM d', locale).format(item.workDate)),
                          onPressed: () => onSelectDay(item.workDate),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _AttendanceSummaryCard extends StatelessWidget {
  const _AttendanceSummaryCard({required this.item});
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
                  l10n.tabTimesheet,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              StatusChip(
                label: _statusLabel(context, item),
                kind: item.isLate ? StatusKind.warning : StatusKind.success,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _row(context, l10n.checkInLabel, item.actualCheckIn == null ? l10n.dash : DateFormat('HH:mm', locale).format(item.actualCheckIn!)),
          _row(context, l10n.checkOutLabel, item.actualCheckOut == null ? l10n.dash : DateFormat('HH:mm', locale).format(item.actualCheckOut!)),
          _row(context, l10n.worked, formatDurationMinutes(context, item.workedMinutes)),
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
                kind: item.correctnessStatus == 'PENDING'
                    ? StatusKind.warning
                    : item.correctnessStatus == 'REJECTED'
                        ? StatusKind.error
                        : item.isLate
                            ? StatusKind.warning
                            : StatusKind.success,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _row(context, l10n.checkInLabel, item.actualCheckIn == null ? l10n.dash : DateFormat('HH:mm', locale).format(item.actualCheckIn!)),
          _row(context, l10n.checkOutLabel, item.actualCheckOut == null ? l10n.dash : DateFormat('HH:mm', locale).format(item.actualCheckOut!)),
          if (item.checkOutSourceLabel != null) _row(context, 'Closed by', item.checkOutSourceLabel!),
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
  const _WorksheetCard({required this.item, required this.onEdit});
  final WorksheetHistoryItem item;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final isReviewed = item.status.toUpperCase() == 'REVIEWED';

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
                label: isReviewed ? l10n.reviewed : l10n.submitted,
                kind: isReviewed ? StatusKind.neutral : StatusKind.success,
              ),
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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(l10n.editWorksheet),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
            ),
          ),
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
  if (i.correctnessStatus == 'PENDING') return l10n.attendanceCorrectionStatusPending;
  if (i.correctnessStatus == 'APPROVED') return l10n.attendanceCorrectionStatusApproved;
  if (i.correctnessStatus == 'REJECTED') return l10n.attendanceCorrectionStatusRejected;
  if (i.isLate) return l10n.late;
  if (i.actualCheckIn == null) return l10n.dash;
  return l10n.onTime;
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}

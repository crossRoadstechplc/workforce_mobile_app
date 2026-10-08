import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../auth/application/session_controller.dart';
import '../data/history_models.dart';
import '../data/history_repository.dart';
import '../history_date_utils.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) => HistoryRepository(ref.watch(dioProvider)));

class HistoryState {
  const HistoryState({
    required this.visibleMonth,
    this.loadedMonthKeys = const {},
    this.timesheets = const [],
    this.worksheets = const [],
    this.holidays = const [],
    this.correctnessByDate = const {},
  });

  final DateTime visibleMonth;
  final Set<String> loadedMonthKeys;
  final List<TimesheetHistoryItem> timesheets;
  final List<WorksheetHistoryItem> worksheets;
  final List<HolidayHistoryItem> holidays;
  final Map<String, String> correctnessByDate;

  HistoryState copyWith({
    DateTime? visibleMonth,
    Set<String>? loadedMonthKeys,
    List<TimesheetHistoryItem>? timesheets,
    List<WorksheetHistoryItem>? worksheets,
    List<HolidayHistoryItem>? holidays,
    Map<String, String>? correctnessByDate,
  }) {
    return HistoryState(
      visibleMonth: visibleMonth ?? this.visibleMonth,
      loadedMonthKeys: loadedMonthKeys ?? this.loadedMonthKeys,
      timesheets: timesheets ?? this.timesheets,
      worksheets: worksheets ?? this.worksheets,
      holidays: holidays ?? this.holidays,
      correctnessByDate: correctnessByDate ?? this.correctnessByDate,
    );
  }

  String? correctnessForDay(DateTime day) {
    final key = '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final fromItem = timesheets.where((e) => isSameCalendarDay(e.workDate, day)).map((e) => e.correctnessStatus).whereType<String>().firstOrNull;
    return fromItem ?? correctnessByDate[key];
  }

  HolidayHistoryItem? holidayForDay(DateTime day) {
    for (final h in holidays) {
      if (isSameCalendarDay(h.workDate, day)) return h;
    }
    return null;
  }
}

final historyControllerProvider = AsyncNotifierProvider<HistoryController, HistoryState>(HistoryController.new);

class HistoryController extends AsyncNotifier<HistoryState> {
  @override
  Future<HistoryState> build() async {
    final userId = ref.watch(sessionControllerProvider.select((s) => s.user?.id));
    if (userId == null) {
      return HistoryState(visibleMonth: monthStart(DateTime.now()));
    }
    final now = monthStart(DateTime.now());
    final months = <DateTime>[];
    for (var i = 6; i >= 0; i--) {
      months.add(DateTime(now.year, now.month - i));
    }
    final state = HistoryState(visibleMonth: now);
    return await _ensureMonths(state, months);
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current == null) {
      state = await AsyncValue.guard(() => build());
      return;
    }
    state = const AsyncLoading();
    final keys = current.loadedMonthKeys.toList();
    final fresh = HistoryState(visibleMonth: current.visibleMonth);
    state = await AsyncValue.guard(() => _ensureMonths(fresh, keys.map(parseMonthKey).toList()));
  }

  Future<void> onVisibleMonthChanged(DateTime month) async {
    final current = state.value;
    if (current == null) return;

    final normalized = monthStart(month);
    state = AsyncData(current.copyWith(visibleMonth: normalized));
    await ensureMonthsAround(normalized);
  }

  Future<void> prefetchEarlier(DateTime month) async {
    final current = state.value;
    if (current == null) return;

    final prev = _prevMonth(month);
    final next = await _ensureMonths(current, [prev]);
    if (next.loadedMonthKeys.length > current.loadedMonthKeys.length) {
      state = AsyncData(next);
    }
  }

  Future<void> submitCorrectnessRequests({
    List<String> dates = const [],
    List<Map<String, dynamic>> days = const [],
    String? note,
  }) async {
    final repository = ref.read(historyRepositoryProvider);
    await repository.submitCorrectnessRequests(dates: dates, days: days, note: note);
    await refresh();
  }

  Future<void> ensureMonthsAround(DateTime month) async {
    final current = state.value;
    if (current == null) return;

    final targets = [month, _prevMonth(month), _nextMonth(month)];
    final next = await _ensureMonths(current, targets);
    if (next.loadedMonthKeys.length != current.loadedMonthKeys.length) {
      state = AsyncData(next);
    }
  }

  Future<HistoryState> _ensureMonths(HistoryState base, List<DateTime> months) async {
    final repository = ref.read(historyRepositoryProvider);
    var result = base;
    final today = DateTime.now();

    for (final month in months) {
      final key = monthKey(month);
      if (result.loadedMonthKeys.contains(key)) continue;
      if (monthStart(month).isAfter(monthStart(today))) continue;

      final from = DateTime(month.year, month.month, 1);
      final to = DateTime(month.year, month.month + 1, 0);
      final results = await Future.wait([
        repository.timesheetCalendar(month.year, month.month),
        repository.worksheetCalendar(month.year, month.month),
        repository.myHolidays(from: from, to: to),
      ]);

      final timesheets = [...result.timesheets, ...results[0] as List<TimesheetHistoryItem>];
      final worksheets = [...result.worksheets, ...results[1] as List<WorksheetHistoryItem>];
      final holidays = [...result.holidays, ...results[2] as List<HolidayHistoryItem>];
      result = result.copyWith(
        loadedMonthKeys: {...result.loadedMonthKeys, key},
        timesheets: timesheets,
        worksheets: worksheets,
        holidays: holidays,
      );
    }

    return result;
  }

  DateTime _prevMonth(DateTime month) {
    final m = monthStart(month);
    return DateTime(m.year, m.month - 1);
  }

  DateTime _nextMonth(DateTime month) {
    final m = monthStart(month);
    return DateTime(m.year, m.month + 1);
  }
}

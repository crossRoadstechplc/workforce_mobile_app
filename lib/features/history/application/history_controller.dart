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
  });

  final DateTime visibleMonth;
  final Set<String> loadedMonthKeys;
  final List<TimesheetHistoryItem> timesheets;
  final List<WorksheetHistoryItem> worksheets;

  HistoryState copyWith({
    DateTime? visibleMonth,
    Set<String>? loadedMonthKeys,
    List<TimesheetHistoryItem>? timesheets,
    List<WorksheetHistoryItem>? worksheets,
  }) {
    return HistoryState(
      visibleMonth: visibleMonth ?? this.visibleMonth,
      loadedMonthKeys: loadedMonthKeys ?? this.loadedMonthKeys,
      timesheets: timesheets ?? this.timesheets,
      worksheets: worksheets ?? this.worksheets,
    );
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

      final results = await Future.wait([
        repository.timesheetCalendar(month.year, month.month),
        repository.worksheetCalendar(month.year, month.month),
      ]);

      final timesheets = [...result.timesheets, ...results[0] as List<TimesheetHistoryItem>];
      final worksheets = [...result.worksheets, ...results[1] as List<WorksheetHistoryItem>];
      result = result.copyWith(
        loadedMonthKeys: {...result.loadedMonthKeys, key},
        timesheets: timesheets,
        worksheets: worksheets,
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

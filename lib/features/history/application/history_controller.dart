import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../data/history_models.dart';
import '../data/history_repository.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) => HistoryRepository(ref.watch(dioProvider)));

class HistoryState {
  const HistoryState({required this.month, this.timesheets = const [], this.worksheets = const []});
  final DateTime month;
  final List<TimesheetHistoryItem> timesheets;
  final List<WorksheetHistoryItem> worksheets;
}

final historyControllerProvider = AsyncNotifierProvider<HistoryController, HistoryState>(HistoryController.new);

class HistoryController extends AsyncNotifier<HistoryState> {
  @override
  Future<HistoryState> build() => _load(DateTime(DateTime.now().year, DateTime.now().month));

  Future<HistoryState> _load(DateTime month) async {
    final repository = ref.read(historyRepositoryProvider);
    final results = await Future.wait([
      repository.timesheetCalendar(month.year, month.month),
      repository.worksheetCalendar(month.year, month.month),
    ]);
    return HistoryState(month: month, timesheets: results[0] as List<TimesheetHistoryItem>, worksheets: results[1] as List<WorksheetHistoryItem>);
  }

  Future<void> changeMonth(DateTime month) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(DateTime(month.year, month.month)));
  }

  Future<void> refresh() async {
    final month = state.value?.month ?? DateTime.now();
    state = await AsyncValue.guard(() => _load(month));
  }
}

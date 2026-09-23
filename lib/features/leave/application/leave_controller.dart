import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../auth/application/session_controller.dart';
import '../../history/application/history_controller.dart';
import '../data/attendance_correction_models.dart';
import '../data/leave_models.dart';
import '../data/leave_repository.dart';

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) => LeaveRepository(ref.watch(dioProvider)));

class LeaveState {
  const LeaveState({
    this.types = const [],
    this.requests = const [],
    this.corrections = const [],
    this.summary = const LeaveSummary(),
    this.balance,
  });
  final List<LeaveType> types;
  final List<LeaveRequestItem> requests;
  final List<AttendanceCorrectionRequest> corrections;
  final LeaveSummary summary;
  final AnnualLeaveBalance? balance;

  Set<String> get blockedCorrectionDateKeys => corrections
      .where((c) => c.status == 'PENDING' || c.status == 'APPROVED')
      .map((c) =>
          '${c.workDate.year.toString().padLeft(4, '0')}-${c.workDate.month.toString().padLeft(2, '0')}-${c.workDate.day.toString().padLeft(2, '0')}')
      .toSet();
}

final leaveControllerProvider = AsyncNotifierProvider<LeaveController, LeaveState>(LeaveController.new);

class LeaveController extends AsyncNotifier<LeaveState> {
  @override
  Future<LeaveState> build() async {
    final userId = ref.watch(sessionControllerProvider.select((s) => s.user?.id));
    if (userId == null) return const LeaveState();
    return _load();
  }

  Future<LeaveState> _load() async {
    final r = ref.read(leaveRepositoryProvider);
    final history = ref.read(historyRepositoryProvider);
    final now = DateTime.now();
    final from = DateTime(now.year, now.month - 6, now.day);
    final values = await Future.wait([
      r.types(),
      r.list(),
      r.summary(),
      history.listCorrectnessRequests(from: from, to: now),
    ]);
    final summary = values[2] as LeaveSummary;
    final correctionJson = values[3] as List<Map<String, dynamic>>;
    return LeaveState(
      types: values[0] as List<LeaveType>,
      requests: values[1] as List<LeaveRequestItem>,
      corrections: correctionJson.map(AttendanceCorrectionRequest.fromJson).toList(),
      summary: summary,
      balance: summary.annualLeave,
    );
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  Future<void> create({required String leaveTypeId, required DateTime startDate, required DateTime endDate, required String reason}) async {
    await ref.read(leaveRepositoryProvider).create(leaveTypeId: leaveTypeId, startDate: startDate, endDate: endDate, reason: reason);
    await refresh();
  }

  Future<void> cancel(String id) async {
    await ref.read(leaveRepositoryProvider).cancel(id);
    await refresh();
  }

  Future<void> submitCorrections(List<String> dates, {String? note}) async {
    await ref.read(historyRepositoryProvider).submitCorrectnessRequests(dates, note: note);
    await refresh();
  }
}

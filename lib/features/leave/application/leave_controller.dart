import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../auth/application/session_controller.dart';
import '../data/leave_models.dart';
import '../data/leave_repository.dart';

final leaveRepositoryProvider = Provider<LeaveRepository>((ref)=>LeaveRepository(ref.watch(dioProvider)));

class LeaveState {
  const LeaveState({this.types=const[],this.requests=const[],this.summary=const LeaveSummary()});
  final List<LeaveType> types; final List<LeaveRequestItem> requests; final LeaveSummary summary;
}
final leaveControllerProvider=AsyncNotifierProvider<LeaveController,LeaveState>(LeaveController.new);
class LeaveController extends AsyncNotifier<LeaveState>{
  @override Future<LeaveState> build() async {
    final userId = ref.watch(sessionControllerProvider.select((s) => s.user?.id));
    if (userId == null) return const LeaveState();
    return _load();
  }
  Future<LeaveState> _load() async { final r=ref.read(leaveRepositoryProvider); final values=await Future.wait([r.types(),r.list(),r.summary()]); return LeaveState(types:values[0] as List<LeaveType>,requests:values[1] as List<LeaveRequestItem>,summary:values[2] as LeaveSummary); }
  Future<void> refresh() async { state=await AsyncValue.guard(_load); }
  Future<void> create({required String leaveTypeId,required DateTime startDate,required DateTime endDate,required String reason}) async { await ref.read(leaveRepositoryProvider).create(leaveTypeId:leaveTypeId,startDate:startDate,endDate:endDate,reason:reason); await refresh(); }
  Future<void> cancel(String id) async { await ref.read(leaveRepositoryProvider).cancel(id); await refresh(); }
}

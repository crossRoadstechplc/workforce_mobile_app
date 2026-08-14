import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_client.dart';
import '../../../core/location/location_service.dart';
import '../../auth/application/session_controller.dart';
import '../data/attendance_models.dart';
import '../data/attendance_repository.dart';

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) => AttendanceRepository(ref.watch(dioProvider)));

class AttendanceState {
  const AttendanceState({this.timesheet, this.loading = false, this.error});
  final Timesheet? timesheet;
  final bool loading;
  final String? error;
}

final attendanceControllerProvider = AsyncNotifierProvider<AttendanceController, AttendanceState>(AttendanceController.new);

final officeContextProvider = FutureProvider<OfficeContext>((ref) async {
  final userId = ref.watch(sessionControllerProvider.select((s) => s.user?.id));
  if (userId == null) {
    throw StateError('Not authenticated');
  }
  final office = await ref.watch(attendanceRepositoryProvider).officeContext();
  // Keep mock GPS anchored to this employee's office so UI matches check-in rules.
  ref.read(locationServiceProvider).setMockAnchor(office.latitude, office.longitude);
  return office;
});

class AttendanceController extends AsyncNotifier<AttendanceState> {
  late final AttendanceRepository _repository;
  late final LocationService _locationService;
  static const _uuid = Uuid();

  @override
  Future<AttendanceState> build() async {
    final userId = ref.watch(sessionControllerProvider.select((s) => s.user?.id));
    if (userId == null) {
      return const AttendanceState();
    }
    _repository = ref.read(attendanceRepositoryProvider);
    _locationService = ref.read(locationServiceProvider);
    final current = await _repository.current();
    return AttendanceState(timesheet: current);
  }

  Future<CheckInAttempt> prepareCheckIn() async {
    final currentState = state.value ?? const AttendanceState();
    state = AsyncData(AttendanceState(timesheet: currentState.timesheet, loading: true));
    try {
      final location = await _locationService.capture();
      final preview = await _repository.preview(location);
      state = AsyncData(AttendanceState(timesheet: currentState.timesheet));
      return CheckInAttempt(location: location, preview: preview);
    } catch (error) {
      state = AsyncData(AttendanceState(timesheet: currentState.timesheet, error: error.toString()));
      rethrow;
    }
  }

  Future<Timesheet> confirmCheckIn(
    CheckInAttempt attempt, {
    String? lateReasonType,
    String? lateReasonDescription,
    String? photoUrl,
  }) async {
    final currentState = state.value ?? const AttendanceState();
    state = AsyncData(AttendanceState(timesheet: currentState.timesheet, loading: true));
    try {
      final location = await _locationService.capture();
      final result = await _repository.checkIn(
        location: location,
        idempotencyKey: _uuid.v4(),
        lateReasonType: lateReasonType,
        lateReasonDescription: lateReasonDescription,
        photoUrl: photoUrl,
      );
      state = AsyncData(AttendanceState(timesheet: result));
      return result;
    } catch (error) {
      state = AsyncData(AttendanceState(timesheet: currentState.timesheet, error: error.toString()));
      rethrow;
    }
  }

  Future<Timesheet> checkOut(String workDescription, {String? photoUrl}) async {
    final currentState = state.value ?? const AttendanceState();
    state = AsyncData(AttendanceState(timesheet: currentState.timesheet, loading: true));
    try {
      final location = await _locationService.capture();
      final result = await _repository.checkOut(
        location: location,
        idempotencyKey: _uuid.v4(),
        workDescription: workDescription,
        photoUrl: photoUrl,
      );
      state = AsyncData(AttendanceState(timesheet: result));
      return result;
    } catch (error) {
      state = AsyncData(AttendanceState(timesheet: currentState.timesheet, error: error.toString()));
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => AttendanceState(timesheet: await _repository.current()));
  }
}

class CheckInAttempt {
  const CheckInAttempt({required this.location, required this.preview});
  final AttendanceLocation location;
  final CheckInPreview preview;
}

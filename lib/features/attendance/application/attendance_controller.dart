import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_client.dart';
import '../../../core/location/location_service.dart';
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

class AttendanceController extends AsyncNotifier<AttendanceState> {
  late final AttendanceRepository _repository;
  late final LocationService _locationService;
  static const _uuid = Uuid();

  @override
  Future<AttendanceState> build() async {
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
  }) async {
    final currentState = state.value ?? const AttendanceState();
    state = AsyncData(AttendanceState(timesheet: currentState.timesheet, loading: true));
    try {
      // Recapture so location is fresh after the late-reason sheet.
      final location = await _locationService.capture();
      final result = await _repository.checkIn(
        location: location,
        idempotencyKey: _uuid.v4(),
        lateReasonType: lateReasonType,
        lateReasonDescription: lateReasonDescription,
      );
      state = AsyncData(AttendanceState(timesheet: result));
      return result;
    } catch (error) {
      state = AsyncData(AttendanceState(timesheet: currentState.timesheet, error: error.toString()));
      rethrow;
    }
  }

  Future<Timesheet> checkOut(String workDescription) async {
    final currentState = state.value ?? const AttendanceState();
    state = AsyncData(AttendanceState(timesheet: currentState.timesheet, loading: true));
    try {
      final location = await _locationService.capture();
      final result = await _repository.checkOut(
        location: location,
        idempotencyKey: _uuid.v4(),
        workDescription: workDescription,
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

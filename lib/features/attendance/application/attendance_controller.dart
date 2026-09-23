import 'dart:typed_data';

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
      final office = await _repository.officeContext();
      if (!office.locationRequired) {
        final preview = await _repository.preview();
        state = AsyncData(AttendanceState(timesheet: currentState.timesheet));
        return CheckInAttempt(preview: preview);
      }
      final location = (await _locationService.captureForAction()).withFreshCapturedAt();
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
      AttendanceLocation? location = attempt.location;
      if (location != null) {
        final age = DateTime.now().toUtc().difference(location.capturedAt);
        location = age.inMinutes >= 4
            ? (await _locationService.captureForAction()).withFreshCapturedAt()
            : location.withFreshCapturedAt();
      }
      final result = await _repository.checkIn(
        location: location,
        idempotencyKey: _uuid.v4(),
        lateReasonType: lateReasonType,
        lateReasonDescription: lateReasonDescription,
        photoUrl: photoUrl,
      );
      final current = await _repository.current();
      state = AsyncData(AttendanceState(timesheet: current));
      return result;
    } catch (error) {
      state = AsyncData(AttendanceState(timesheet: currentState.timesheet, error: error.toString()));
      rethrow;
    }
  }

  Future<Timesheet> checkOut({
    String? workDescription,
    String? photoUrl,
    AttendanceLocation? location,
  }) async {
    final currentState = state.value ?? const AttendanceState();
    state = AsyncData(AttendanceState(timesheet: currentState.timesheet, loading: true));
    try {
      final office = await _repository.officeContext();
      final AttendanceLocation? fix;
      if (office.locationRequired) {
        fix = location != null
            ? location.withFreshCapturedAt()
            : (await _locationService.captureForAction()).withFreshCapturedAt();
      } else {
        fix = null;
      }
      final result = await _repository.checkOut(
        location: fix,
        idempotencyKey: _uuid.v4(),
        workDescription: workDescription,
        photoUrl: photoUrl,
      );
      final current = await _repository.current();
      state = AsyncData(AttendanceState(timesheet: current));
      return result;
    } catch (error) {
      state = AsyncData(AttendanceState(timesheet: currentState.timesheet, error: error.toString()));
      rethrow;
    }
  }

  Future<OfficeContext> latestOfficeContext() async {
    return _repository.officeContext();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => AttendanceState(timesheet: await _repository.current()));
  }

  Future<String> uploadAttendancePhoto({
    required Uint8List bytes,
    required String mimeType,
    required String purpose,
  }) async {
    final upload = await _repository.uploadPhoto(bytes: bytes, mimeType: mimeType, purpose: purpose);
    return upload.url;
  }
}

class CheckInAttempt {
  const CheckInAttempt({this.location, required this.preview});
  final AttendanceLocation? location;
  final CheckInPreview preview;
}

import 'package:dio/dio.dart';

import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/location/location_service.dart';
import 'attendance_models.dart';

class AttendanceRepository {
  AttendanceRepository(this._dio);
  final Dio _dio;

  Future<Timesheet?> current() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.currentAttendance);
      final data = response.data?['data'];
      if (data == null) return null;
      return Timesheet.fromJson(data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<CheckInPreview> preview(AttendanceLocation location) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.checkInPreview,
        data: location.toJson(),
      );
      return CheckInPreview.fromJson(response.data!['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Timesheet> checkIn({
    required AttendanceLocation location,
    required String idempotencyKey,
    String? lateReasonType,
    String? lateReasonDescription,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.checkIn,
        data: {
          ...location.toJson(),
          'idempotencyKey': idempotencyKey,
          if (lateReasonType != null) 'lateReasonType': lateReasonType,
          if (lateReasonDescription?.trim().isNotEmpty == true) 'lateReasonDescription': lateReasonDescription!.trim(),
        },
      );
      return Timesheet.fromJson(response.data!['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Timesheet> checkOut({
    required AttendanceLocation location,
    required String idempotencyKey,
    required String workDescription,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.checkOut,
        data: {
          ...location.toJson(),
          'idempotencyKey': idempotencyKey,
          'workDescription': workDescription.trim(),
        },
      );
      return Timesheet.fromJson(response.data!['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

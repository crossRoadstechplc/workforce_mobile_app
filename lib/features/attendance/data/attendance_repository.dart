import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/location/location_service.dart';
import 'attendance_models.dart';

class AttendancePhotoUpload {
  const AttendancePhotoUpload({required this.url, required this.publicId});
  final String url;
  final String publicId;

  factory AttendancePhotoUpload.fromJson(Map<String, dynamic> json) => AttendancePhotoUpload(
        url: json['url'] as String,
        publicId: json['publicId'] as String,
      );
}

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

  Future<OfficeContext> officeContext() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.attendanceContext);
      return OfficeContext.fromJson(response.data!['data'] as Map<String, dynamic>);
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
    String? photoUrl,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.checkIn,
        data: {
          ...location.toJson(),
          'idempotencyKey': idempotencyKey,
          if (lateReasonType != null) 'lateReasonType': lateReasonType,
          if (lateReasonDescription?.trim().isNotEmpty == true) 'lateReasonDescription': lateReasonDescription!.trim(),
          if (photoUrl != null) 'photoUrl': photoUrl,
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
    String? photoUrl,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.checkOut,
        data: {
          ...location.toJson(),
          'idempotencyKey': idempotencyKey,
          'workDescription': workDescription.trim(),
          if (photoUrl != null) 'photoUrl': photoUrl,
        },
      );
      return Timesheet.fromJson(response.data!['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<AttendancePhotoUpload> uploadPhoto({
    required Uint8List bytes,
    required String mimeType,
    required String purpose,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.attendancePhotos,
        data: {
          'purpose': purpose,
          'mimeType': mimeType,
          'imageBase64': base64Encode(bytes),
        },
      );
      return AttendancePhotoUpload.fromJson(response.data!['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

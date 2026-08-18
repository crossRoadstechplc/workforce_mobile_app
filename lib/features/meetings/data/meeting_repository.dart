import 'package:dio/dio.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_exception.dart';
import 'meeting_models.dart';

class MeetingRepository {
  MeetingRepository(this._dio);
  final Dio _dio;

  Future<List<MeetingRoom>> rooms() async {
    try {
      final r = await _dio.get<Map<String, dynamic>>(ApiEndpoints.meetingRooms, queryParameters: {'page': 1, 'pageSize': 100});
      final data = r.data?['data'] as Map<String, dynamic>? ?? const {};
      final list = data['items'] as List<dynamic>? ?? const [];
      return list.map((e) => MeetingRoom.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<MeetingBusySlot>> availability(String roomId, DateTime date) async {
    try {
      final key = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final r = await _dio.get<Map<String, dynamic>>('${ApiEndpoints.meetingRooms}/$roomId/availability', queryParameters: {'date': key});
      final data = r.data?['data'] as Map<String, dynamic>? ?? const {};
      final list = data['busy'] as List<dynamic>? ?? const [];
      return list.map((e) => MeetingBusySlot.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<MeetingBooking>> list() async {
    try {
      final r = await _dio.get<Map<String, dynamic>>(ApiEndpoints.meetingBookings, queryParameters: {'page': 1, 'pageSize': 50});
      final data = r.data?['data'] as Map<String, dynamic>? ?? const {};
      final list = data['items'] as List<dynamic>? ?? const [];
      return list.map((e) => MeetingBooking.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<MeetingBooking> book({
    required String roomId,
    required String title,
    required DateTime startsAt,
    required DateTime endsAt,
    String? notes,
  }) async {
    try {
      final r = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.meetingBookings,
        data: {
          'roomId': roomId,
          'title': title.trim(),
          'startsAt': startsAt.toUtc().toIso8601String(),
          'endsAt': endsAt.toUtc().toIso8601String(),
          if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        },
      );
      return MeetingBooking.fromJson(r.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> cancel(String id) async {
    try {
      await _dio.post<Map<String, dynamic>>('${ApiEndpoints.meetingBookings}/$id/cancel', data: {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

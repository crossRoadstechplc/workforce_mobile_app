import 'package:dio/dio.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_exception.dart';
import 'history_models.dart';

class HistoryRepository {
  HistoryRepository(this._dio);
  final Dio _dio;

  Future<List<TimesheetHistoryItem>> timesheetCalendar(int year, int month) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.timesheetCalendar, queryParameters: {'year': year, 'month': month});
      final items = response.data?['data'] as List<dynamic>? ?? const [];
      return items.map((e) => TimesheetHistoryItem.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<List<WorksheetHistoryItem>> worksheetCalendar(int year, int month) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.worksheetCalendar, queryParameters: {'year': year, 'month': month});
      final items = response.data?['data'] as List<dynamic>? ?? const [];
      return items.map((e) => WorksheetHistoryItem.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (error) { throw ApiException.fromDio(error); }
  }

  Future<TimesheetHistoryItem> timesheet(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('${ApiEndpoints.timesheets}/$id');
      return TimesheetHistoryItem.fromJson(response.data!['data'] as Map<String, dynamic>);
    } on DioException catch (error) { throw ApiException.fromDio(error); }
  }

  Future<WorksheetHistoryItem> worksheet(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('${ApiEndpoints.worksheets}/$id');
      return WorksheetHistoryItem.fromJson(response.data!['data'] as Map<String, dynamic>);
    } on DioException catch (error) { throw ApiException.fromDio(error); }
  }

  Future<WorksheetHistoryItem> createWorksheet({
    required String timesheetId,
    required String workDescription,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.worksheets,
        data: {
          'timesheetId': timesheetId,
          'workDescription': workDescription.trim(),
        },
      );
      return WorksheetHistoryItem.fromJson(response.data!['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<WorksheetHistoryItem> updateWorksheet({
    required String worksheetId,
    required String workDescription,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '${ApiEndpoints.worksheets}/$worksheetId',
        data: {'workDescription': workDescription.trim()},
      );
      return WorksheetHistoryItem.fromJson(response.data!['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> submitCorrectnessRequests(List<String> dates, {String? note}) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.attendanceCorrectnessRequests,
        data: {
          'dates': dates,
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        },
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<List<Map<String, dynamic>>> listCorrectnessRequests({DateTime? from, DateTime? to}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.attendanceCorrectnessRequests,
        queryParameters: {
          if (from != null) 'from': _dateKey(from),
          if (to != null) 'to': _dateKey(to),
        },
      );
      final items = response.data?['data'] as List<dynamic>? ?? const [];
      return items.map((e) => e as Map<String, dynamic>).toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

String _dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

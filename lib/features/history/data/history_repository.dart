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
    } on DioException catch (error) { throw ApiException.fromDio(error); }
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
}

import 'package:dio/dio.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_exception.dart';
import 'leave_models.dart';

class LeaveRepository {
  LeaveRepository(this._dio); final Dio _dio;

  Future<List<LeaveType>> types() async {
    try { final r=await _dio.get<Map<String,dynamic>>(ApiEndpoints.leaveTypes); final list=r.data?['data'] as List<dynamic>? ?? const []; return list.map((e)=>LeaveType.fromJson(e as Map<String,dynamic>)).toList(); }
    on DioException catch(e){throw ApiException.fromDio(e);} }

  Future<List<LeaveRequestItem>> list({String? status}) async {
    try { final r=await _dio.get<Map<String,dynamic>>(ApiEndpoints.leaveRequests,queryParameters:{'page':1,'pageSize':100,if(status!=null)'status':status}); final data=r.data?['data'] as Map<String,dynamic>? ?? const {}; final list=data['items'] as List<dynamic>? ?? const []; return list.map((e)=>LeaveRequestItem.fromJson(e as Map<String,dynamic>)).toList(); }
    on DioException catch(e){throw ApiException.fromDio(e);} }

  Future<LeaveSummary> summary() async {
    try { final r=await _dio.get<Map<String,dynamic>>(ApiEndpoints.leaveSummary); return LeaveSummary.fromJson(r.data!['data'] as Map<String,dynamic>); }
    on DioException catch(e){throw ApiException.fromDio(e);} }

  Future<LeaveRequestItem> create({required String leaveTypeId, required DateTime startDate, required DateTime endDate, required String reason}) async {
    try { final r=await _dio.post<Map<String,dynamic>>(ApiEndpoints.leaveRequests,data:{'leaveTypeId':leaveTypeId,'startDate':_date(startDate),'endDate':_date(endDate),'reason':reason.trim()}); return LeaveRequestItem.fromJson(r.data!['data'] as Map<String,dynamic>); }
    on DioException catch(e){throw ApiException.fromDio(e);} }

  Future<void> cancel(String id,{String? reason}) async {
    try { await _dio.post<Map<String,dynamic>>('${ApiEndpoints.leaveRequests}/$id/cancel',data:{if(reason?.trim().isNotEmpty==true)'reason':reason!.trim()}); }
    on DioException catch(e){throw ApiException.fromDio(e);} }
}
String _date(DateTime d) => '${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

import 'package:dio/dio.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_exception.dart';
import 'notification_models.dart';
class NotificationRepository{NotificationRepository(this._dio);final Dio _dio;
 Future<NotificationPageData> list() async{try{final r=await _dio.get<Map<String,dynamic>>(ApiEndpoints.notifications,queryParameters:{'page':1,'pageSize':100});final d=r.data?['data'] as Map<String,dynamic>? ?? const{};final list=d['items'] as List<dynamic>? ?? const[];return NotificationPageData(items:list.map((e)=>AppNotification.fromJson(e as Map<String,dynamic>)).toList(),unreadCount:(d['unreadCount'] as num?)?.toInt()??0);}on DioException catch(e){throw ApiException.fromDio(e);}}
 Future<void> markRead(String id) async{try{await _dio.patch('${ApiEndpoints.notifications}/$id/read');}on DioException catch(e){throw ApiException.fromDio(e);}}
 Future<void> markAllRead() async{try{await _dio.patch(ApiEndpoints.notificationReadAll);}on DioException catch(e){throw ApiException.fromDio(e);}}
 Future<void> registerDevice({required String deviceId,required String fcmToken,required String platform}) async{try{await _dio.post(ApiEndpoints.notificationDevices,data:{'deviceId':deviceId,'fcmToken':fcmToken,'platform':platform});}on DioException catch(e){throw ApiException.fromDio(e);}}
 Future<void> removeDevice(String deviceId) async{try{await _dio.delete('${ApiEndpoints.notificationDevices}/$deviceId');}on DioException catch(e){throw ApiException.fromDio(e);}}
}

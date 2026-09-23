import 'package:dio/dio.dart';

import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_exception.dart';
import 'app_version_models.dart';

class AppVersionRepository {
  AppVersionRepository(this._dio);

  final Dio _dio;

  Future<AppVersionInfo> fetch() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.appVersion);
      final data = response.data;
      if (data == null) {
        throw const ApiException('App version payload missing.');
      }
      return AppVersionInfo.fromJson(data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

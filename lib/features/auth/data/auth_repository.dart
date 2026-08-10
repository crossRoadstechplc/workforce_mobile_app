import 'package:dio/dio.dart';

import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_exception.dart';
import 'auth_models.dart';

class AuthRepository {
  AuthRepository(this._dio);
  final Dio _dio;

  Future<AuthSession> login({
    required String login,
    required String password,
    String? deviceId,
    String? organizationSlug,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {
          'login': login.trim(),
          'password': password,
          if (deviceId != null) 'deviceId': deviceId,
          if (organizationSlug != null && organizationSlug.trim().isNotEmpty)
            'organizationSlug': organizationSlug.trim().toLowerCase(),
        },
      );
      return AuthSession.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<AuthSession> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.changePassword,
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
      return AuthSession.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Map<String, dynamic>> me() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.me);
      return response.data!;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post<void>(ApiEndpoints.logout, data: {'refreshToken': refreshToken});
    } on DioException {
      // Local logout must still succeed if the network is unavailable.
    }
  }
}

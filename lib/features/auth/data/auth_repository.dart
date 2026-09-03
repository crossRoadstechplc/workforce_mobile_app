import 'package:dio/dio.dart';

import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_exception.dart';
import 'auth_models.dart';

class AuthRepository {
  AuthRepository(this._dio);
  final Dio _dio;

  Future<LoginResponse> login({
    required String login,
    required String password,
    String? deviceId,
    String? organizationSlug,
    String? lastContextKey,
    String? contextKey,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {
          'login': login.trim(),
          'password': password.trim(),
          if (deviceId != null) 'deviceId': deviceId,
          if (organizationSlug != null && organizationSlug.trim().isNotEmpty)
            'organizationSlug': organizationSlug.trim().toLowerCase(),
          if (lastContextKey != null && lastContextKey.isNotEmpty) 'lastContextKey': lastContextKey,
          if (contextKey != null && contextKey.isNotEmpty) 'contextKey': contextKey,
        },
      );
      return LoginResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<AuthSession> selectContext({
    required String preAuthToken,
    required String contextKey,
    String? deviceId,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.selectContext,
        data: {
          'preAuthToken': preAuthToken,
          'contextKey': contextKey,
          if (deviceId != null) 'deviceId': deviceId,
        },
      );
      return AuthSession.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<AuthSession> switchContext({
    required String contextKey,
    String? deviceId,
    String? refreshToken,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.switchContext,
        data: {
          'contextKey': contextKey,
          if (deviceId != null) 'deviceId': deviceId,
          if (refreshToken != null) 'refreshToken': refreshToken,
        },
      );
      return AuthSession.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<List<LoginContext>> listContexts() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.contexts);
      final items = response.data?['contexts'] as List<dynamic>? ?? const [];
      return items.map((item) => LoginContext.fromJson(item as Map<String, dynamic>)).toList();
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

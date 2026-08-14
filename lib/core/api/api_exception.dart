import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  factory ApiException.fromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final code = (data['code'] ?? data['error']?['code'])?.toString();
      final rawMessage = (data['message'] ?? data['error']?['message'] ?? 'Request failed').toString();
      final message = switch (code) {
        'NOT_FOUND' when rawMessage == 'Route not found' =>
          'Server route not found. Rebuild the app with API_BASE_URL ending in /api/v1.',
        'STALE_LOCATION' =>
          'Location timestamp was rejected. Enable automatic date & time on your phone, then try again.',
        _ => rawMessage,
      };
      return ApiException(
        message,
        code: code,
        statusCode: error.response?.statusCode,
      );
    }
    return ApiException(
      error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError
          ? 'Unable to connect to the server.'
          : 'Something went wrong. Please try again.',
      statusCode: error.response?.statusCode,
    );
  }

  @override
  String toString() => message;
}

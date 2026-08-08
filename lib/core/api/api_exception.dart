import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  factory ApiException.fromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      return ApiException(
        (data['message'] ?? data['error']?['message'] ?? 'Request failed').toString(),
        code: (data['code'] ?? data['error']?['code'])?.toString(),
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

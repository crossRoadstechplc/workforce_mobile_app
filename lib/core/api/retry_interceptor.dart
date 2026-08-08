import 'dart:async';

import 'package:dio/dio.dart';

/// Retries only safe GET requests for transient transport/server failures.
/// Business mutations (check-in, checkout, leave requests) are never
/// automatically retried here; they use backend idempotency where appropriate.
class SafeRetryInterceptor extends Interceptor {
  SafeRetryInterceptor(this.dio);
  final Dio dio;

  static const _maxRetries = 2;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final retries = request.extra['safeRetryCount'] as int? ?? 0;

    if (request.method.toUpperCase() != 'GET' ||
        retries >= _maxRetries ||
        !_isTransient(err)) {
      handler.next(err);
      return;
    }

    await Future<void>.delayed(Duration(milliseconds: 350 * (retries + 1)));
    try {
      final response = await dio.fetch<dynamic>(
        request.copyWith(extra: {...request.extra, 'safeRetryCount': retries + 1}),
      );
      handler.resolve(response);
    } catch (_) {
      handler.next(err);
    }
  }

  bool _isTransient(DioException error) {
    final underlying = error.error;
    if (underlying is TimeoutException) return true;
    // Avoid dart:io SocketException so this works on web too.
    if (underlying != null && underlying.runtimeType.toString() == 'SocketException') {
      return true;
    }
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.connectionError =>
        true,
      _ => (error.response?.statusCode ?? 0) >= 500,
    };
  }
}

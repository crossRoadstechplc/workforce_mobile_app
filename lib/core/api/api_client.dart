import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../auth/token_storage.dart';
import '../config/app_config.dart';
import 'api_endpoints.dart';
import 'retry_interceptor.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(webOptions: WebOptions());
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(ref.watch(secureStorageProvider));
});

final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.resolvedApiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: const {'Accept': 'application/json', 'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(_AuthInterceptor(dio, tokenStorage));
  dio.interceptors.add(SafeRetryInterceptor(dio));
  return dio;
});

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._dio, this._storage);

  final Dio _dio;
  final TokenStorage _storage;
  Completer<void>? _refreshCompleter;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final isAuthEndpoint = request.path.contains(ApiEndpoints.login) ||
        request.path.contains(ApiEndpoints.refresh);
    final retried = request.extra['retriedAfterRefresh'] == true;

    if (err.response?.statusCode != 401 || isAuthEndpoint || retried) {
      handler.next(err);
      return;
    }

    try {
      await _refreshOnce();
      final accessToken = await _storage.readAccessToken();
      final response = await _dio.fetch<dynamic>(
        request.copyWith(
          headers: {...request.headers, if (accessToken != null) 'Authorization': 'Bearer $accessToken'},
          extra: {...request.extra, 'retriedAfterRefresh': true},
        ),
      );
      handler.resolve(response);
    } catch (_) {
      await _storage.clear();
      handler.next(err);
    }
  }

  Future<void> _refreshOnce() async {
    if (_refreshCompleter != null) return _refreshCompleter!.future;
    final completer = Completer<void>();
    _refreshCompleter = completer;
    try {
      final refreshToken = await _storage.readRefreshToken();
      if (refreshToken == null) throw StateError('No refresh token');
      final bareDio = Dio(BaseOptions(baseUrl: AppConfig.resolvedApiBaseUrl));
      final response = await bareDio.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken, 'deviceId': await _storage.readOrCreateDeviceId()},
      );
      final data = response.data!;
      await _storage.writeTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      completer.complete();
    } catch (error, stack) {
      completer.completeError(error, stack);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../auth/token_refresher.dart';
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

final tokenRefresherProvider = Provider<TokenRefresher>((ref) {
  return TokenRefresher(ref.watch(tokenStorageProvider));
});

final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final tokenRefresher = ref.watch(tokenRefresherProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.resolvedApiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: const {'Accept': 'application/json', 'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(_AuthInterceptor(dio, tokenStorage, tokenRefresher));
  dio.interceptors.add(SafeRetryInterceptor(dio));
  return dio;
});

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._dio, this._storage, this._refresher);

  final Dio _dio;
  final TokenStorage _storage;
  final TokenRefresher _refresher;

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
      await _refresher.refresh();
      final accessToken = await _storage.readAccessToken();
      final response = await _dio.fetch<dynamic>(
        request.copyWith(
          headers: {...request.headers, if (accessToken != null) 'Authorization': 'Bearer $accessToken'},
          extra: {...request.extra, 'retriedAfterRefresh': true},
        ),
      );
      handler.resolve(response);
    } catch (refreshError) {
      // Only clear the session when the backend explicitly rejected the
      // refresh token (401/403). Network blips/timeouts while refreshing
      // must not log the user out - just surface the original error and
      // let the next request try again.
      if (refreshError is DioException) {
        final refreshStatus = refreshError.response?.statusCode;
        if (refreshStatus == 401 || refreshStatus == 403) {
          await _storage.clear();
        }
      } else {
        await _storage.clear();
      }
      handler.next(err);
    }
  }
}

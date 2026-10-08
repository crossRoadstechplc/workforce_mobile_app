import 'dart:async';

import 'package:dio/dio.dart';

import '../api/api_endpoints.dart';
import '../config/app_config.dart';
import 'token_storage.dart';

/// Single-flight access/refresh token rotation shared by HTTP 401 recovery
/// and proactive refresh before expiry.
class TokenRefresher {
  TokenRefresher(this._storage);

  final TokenStorage _storage;
  Completer<void>? _refreshCompleter;

  /// Rotates tokens using the stored refresh token. Concurrent callers share
  /// one in-flight request.
  Future<void> refresh() async {
    if (_refreshCompleter != null) return _refreshCompleter!.future;
    final completer = Completer<void>();
    _refreshCompleter = completer;
    try {
      final refreshToken = await _storage.readRefreshToken();
      if (refreshToken == null) throw StateError('No refresh token');
      final bareDio = Dio(BaseOptions(baseUrl: AppConfig.resolvedApiBaseUrl));
      final response = await bareDio.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        data: {
          'refreshToken': refreshToken,
          'deviceId': await _storage.readOrCreateDeviceId(),
        },
      );
      final data = response.data!;
      await _storage.writeTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
        notifyRefresh: true,
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

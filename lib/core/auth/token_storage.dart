import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;
  final _tokensRefreshed = StreamController<void>.broadcast();
  final _sessionCleared = StreamController<void>.broadcast();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _deviceKey = 'device_id';
  static const _lastContextKey = 'last_context_key';

  /// Fired after a successful access/refresh token rotation (HTTP 401 refresh).
  Stream<void> get onTokensRefreshed => _tokensRefreshed.stream;

  /// Fired when tokens are cleared (failed refresh, logout, revoke).
  Stream<void> get onSessionCleared => _sessionCleared.stream;

  Future<String?> readAccessToken() => _storage.read(key: _accessKey);
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);
  Future<String?> readLastContextKey() => _storage.read(key: _lastContextKey);

  Future<void> writeLastContextKey(String contextKey) =>
      _storage.write(key: _lastContextKey, value: contextKey);

  Future<String> readOrCreateDeviceId() async {
    final existing = await _storage.read(key: _deviceKey);
    if (existing != null && existing.isNotEmpty) return existing;
    const uuid = Uuid();
    final value = uuid.v4();
    await _storage.write(key: _deviceKey, value: value);
    return value;
  }

  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
    bool notifyRefresh = false,
  }) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: accessToken),
      _storage.write(key: _refreshKey, value: refreshToken),
    ]);
    if (notifyRefresh) _tokensRefreshed.add(null);
  }

  Future<void> clearSession({bool notify = true}) async {
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
    ]);
    if (notify) _sessionCleared.add(null);
  }

  Future<void> clear({bool notify = true}) => clearSession(notify: notify);
}

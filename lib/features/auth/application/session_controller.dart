import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/token_storage.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

enum SessionStatus { checking, unauthenticated, mustChangePassword, selectContext, authenticated }

class SessionState {
  const SessionState({
    required this.status,
    this.user,
    this.error,
    this.pendingContext,
    this.availableContexts = const [],
    this.contextSwitching = false,
  });

  final SessionStatus status;
  final AuthUser? user;
  final String? error;
  final PendingLoginSelection? pendingContext;
  final List<LoginContext> availableContexts;
  final bool contextSwitching;

  SessionState copyWith({
    SessionStatus? status,
    AuthUser? user,
    String? error,
    PendingLoginSelection? pendingContext,
    List<LoginContext>? availableContexts,
    bool? contextSwitching,
    bool clearPendingContext = false,
    bool clearError = false,
  }) =>
      SessionState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: clearError ? null : (error ?? this.error),
        pendingContext: clearPendingContext ? null : (pendingContext ?? this.pendingContext),
        availableContexts: availableContexts ?? this.availableContexts,
        contextSwitching: contextSwitching ?? this.contextSwitching,
      );
}

final sessionControllerProvider = NotifierProvider<SessionController, SessionState>(SessionController.new);

class SessionController extends Notifier<SessionState> {
  late final AuthRepository _repository;
  late final TokenStorage _storage;

  @override
  SessionState build() {
    _repository = ref.read(authRepositoryProvider);
    _storage = ref.read(tokenStorageProvider);
    Future.microtask(_restore);
    return const SessionState(status: SessionStatus.checking);
  }

  Future<void> _restore() async {
    final access = await _storage.readAccessToken();
    final refresh = await _storage.readRefreshToken();
    if (access == null || refresh == null) {
      state = const SessionState(status: SessionStatus.unauthenticated);
      return;
    }

    try {
      final identity = await _repository.me();
      final user = AuthUser.fromJson(identity);
      final mustChange = identity['mustChangePassword'] as bool? ?? false;
      final contexts = await _loadAvailableContexts();
      state = SessionState(
        status: mustChange ? SessionStatus.mustChangePassword : SessionStatus.authenticated,
        user: user,
        availableContexts: contexts,
      );
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        await _storage.clear();
      }
      state = const SessionState(status: SessionStatus.unauthenticated);
    } catch (_) {
      state = const SessionState(status: SessionStatus.unauthenticated);
    }
  }

  Future<List<LoginContext>> _loadAvailableContexts() async {
    try {
      return await _repository.listContexts();
    } catch (_) {
      return const [];
    }
  }

  Future<void> login(String login, String password, {String? organizationSlug}) async {
    try {
      final deviceId = await _storage.readOrCreateDeviceId();
      final lastContextKey = await _storage.readLastContextKey();
      final response = await _repository.login(
        login: login,
        password: password,
        deviceId: deviceId,
        organizationSlug: organizationSlug,
        lastContextKey: lastContextKey,
      );

      if (response.requiresContextSelection) {
        await _handlePendingSelection(response.pending!);
        return;
      }

      await _persist(response.session!);
    } catch (error) {
      state = SessionState(status: SessionStatus.unauthenticated, error: error.toString());
      rethrow;
    }
  }

  Future<void> _handlePendingSelection(PendingLoginSelection pending) async {
    final employeeContexts = employeeAppLoginContexts(pending.contexts);
    if (employeeContexts.isEmpty) {
      throw StateError('Employee access required. Use the admin portal for administrator roles.');
    }

    if (employeeContexts.length == 1) {
      await selectContext(employeeContexts.first.key, preAuthToken: pending.preAuthToken);
      return;
    }

    final lastContextKey = await _storage.readLastContextKey();
    String? defaultKey;
    if (lastContextKey != null && employeeContexts.any((item) => item.key == lastContextKey)) {
      defaultKey = lastContextKey;
    } else if (pending.defaultContextKey != null &&
        employeeContexts.any((item) => item.key == pending.defaultContextKey)) {
      defaultKey = pending.defaultContextKey;
    } else {
      defaultKey = employeeContexts.first.key;
    }

    state = SessionState(
      status: SessionStatus.selectContext,
      pendingContext: PendingLoginSelection(
        preAuthToken: pending.preAuthToken,
        contexts: employeeContexts,
        defaultContextKey: defaultKey,
      ),
    );
  }

  Future<void> selectContext(String contextKey, {String? preAuthToken}) async {
    final token = preAuthToken ?? state.pendingContext?.preAuthToken;
    if (token == null) throw StateError('No pending login session');

    try {
      final deviceId = await _storage.readOrCreateDeviceId();
      final session = await _repository.selectContext(
        preAuthToken: token,
        contextKey: contextKey,
        deviceId: deviceId,
      );
      await _persist(session, contextKey: contextKey);
    } catch (error) {
      state = state.copyWith(status: SessionStatus.selectContext, error: error.toString());
      rethrow;
    }
  }

  Future<void> switchContext(String contextKey) async {
    if (contextKey == state.user?.activeContext?.key) return;

    state = state.copyWith(contextSwitching: true, clearError: true);
    try {
      final deviceId = await _storage.readOrCreateDeviceId();
      final refresh = await _storage.readRefreshToken();
      final session = await _repository.switchContext(
        contextKey: contextKey,
        deviceId: deviceId,
        refreshToken: refresh,
      );
      await _persist(session, contextKey: contextKey);
    } catch (error) {
      state = state.copyWith(contextSwitching: false, error: error.toString());
      rethrow;
    }
  }

  void cancelContextSelection() {
    state = const SessionState(status: SessionStatus.unauthenticated);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final session = await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    await _persist(session, contextKey: state.user?.activeContext?.key);
  }

  Future<void> _persist(AuthSession session, {String? contextKey}) async {
    final key = contextKey ?? session.activeContext?.key ?? session.user.activeContext?.key;
    if (key != null && key.isNotEmpty) {
      await _storage.writeLastContextKey(key);
    }
    await _storage.writeTokens(accessToken: session.accessToken, refreshToken: session.refreshToken);
    final contexts = await _loadAvailableContexts();
    state = SessionState(
      status: session.mustChangePassword ? SessionStatus.mustChangePassword : SessionStatus.authenticated,
      user: session.user,
      availableContexts: contexts,
      contextSwitching: false,
    );
  }

  Future<void> logout() async {
    final refresh = await _storage.readRefreshToken();
    if (refresh != null) await _repository.logout(refresh);
    await _storage.clear();
    state = const SessionState(status: SessionStatus.unauthenticated);
  }
}

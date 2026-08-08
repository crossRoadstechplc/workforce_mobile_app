import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/token_storage.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

enum SessionStatus { checking, unauthenticated, mustChangePassword, authenticated }

class SessionState {
  const SessionState({required this.status, this.user, this.error});
  final SessionStatus status;
  final AuthUser? user;
  final String? error;

  SessionState copyWith({SessionStatus? status, AuthUser? user, String? error}) => SessionState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error,
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
      state = SessionState(
        status: mustChange ? SessionStatus.mustChangePassword : SessionStatus.authenticated,
        user: user,
      );
    } catch (_) {
      await _storage.clear();
      state = const SessionState(status: SessionStatus.unauthenticated);
    }
  }

  Future<void> login(String login, String password) async {
    // Keep status as unauthenticated while logging in so the UI stays on
    // /login (button spinner) instead of bouncing to /splash mid-request.
    try {
      final deviceId = await _storage.readOrCreateDeviceId();
      final session = await _repository.login(login: login, password: password, deviceId: deviceId);
      await _persist(session);
    } catch (error) {
      state = SessionState(status: SessionStatus.unauthenticated, error: error.toString());
      rethrow;
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final session = await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    await _persist(session);
  }

  Future<void> _persist(AuthSession session) async {
    await _storage.writeTokens(accessToken: session.accessToken, refreshToken: session.refreshToken);
    state = SessionState(
      status: session.mustChangePassword ? SessionStatus.mustChangePassword : SessionStatus.authenticated,
      user: session.user,
    );
  }

  Future<void> logout() async {
    final refresh = await _storage.readRefreshToken();
    if (refresh != null) await _repository.logout(refresh);
    await _storage.clear();
    state = const SessionState(status: SessionStatus.unauthenticated);
  }
}

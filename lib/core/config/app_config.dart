class AppConfig {
  AppConfig._();

  static const environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  // Defaults target local workforce-backend on this machine (Chrome/Windows).
  // Android emulator: use tool/run.ps1 with .env values set to 10.0.2.2
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:4000/api/v1',
  );

  /// Ensures REST calls always target `/api/v1`, even when the build flag
  /// omits that suffix (a common release-packaging mistake).
  static String get resolvedApiBaseUrl {
    var url = apiBaseUrl.trim();
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (!url.endsWith('/api/v1')) {
      url = '$url/api/v1';
    }
    return url;
  }

  static const socketBaseUrl = String.fromEnvironment(
    'SOCKET_BASE_URL',
    defaultValue: 'http://127.0.0.1:4000',
  );

  static const enableFirebase = bool.fromEnvironment(
    'ENABLE_FIREBASE',
    defaultValue: false,
  );

  static const taskTrackerUrl = String.fromEnvironment(
    'TASK_TRACKER_URL',
    defaultValue: 'http://127.0.0.1:3001',
  );

  /// Baked at build time from `.env` / `--dart-define=APP_VERSION=...`.
  /// Compared against the backend `GET /api/v1/app/version` payload.
  static const appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );

  static String get resolvedTaskTrackerUrl {
    var url = taskTrackerUrl.trim();
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 20);

  static bool get isProduction => environment.toLowerCase() == 'production';

  static void validate() {
    const valid = {'development', 'staging', 'production'};
    if (!valid.contains(environment.toLowerCase())) {
      throw StateError('Unsupported APP_ENV: $environment');
    }

    final api = Uri.tryParse(resolvedApiBaseUrl);
    final socket = Uri.tryParse(socketBaseUrl);
    if (api == null || !api.hasScheme || api.host.isEmpty) {
      throw StateError('API_BASE_URL is invalid.');
    }
    if (socket == null || !socket.hasScheme || socket.host.isEmpty) {
      throw StateError('SOCKET_BASE_URL is invalid.');
    }

    if (isProduction && (api.scheme != 'https' || socket.scheme != 'https')) {
      throw StateError('Production API and Socket URLs must use HTTPS.');
    }

    if (isProduction && api.host == '10.0.2.2') {
      throw StateError('Development API URL cannot be used in production.');
    }
  }
}

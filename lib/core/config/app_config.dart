class AppConfig {
  AppConfig._();

  static const environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000/api/v1',
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
    defaultValue: 'http://10.0.2.2:4000',
  );

  static const enableFirebase = bool.fromEnvironment(
    'ENABLE_FIREBASE',
    defaultValue: false,
  );

  /// When true (default in local development), attendance uses seeded office
  /// coordinates so Chrome/emulator check-in works against demo data.
  /// Set `--dart-define=USE_MOCK_ATTENDANCE_LOCATION=false` to use real GPS.
  static const useMockAttendanceLocation = bool.fromEnvironment(
    'USE_MOCK_ATTENDANCE_LOCATION',
    defaultValue: true,
  );

  static const mockAttendanceLatitude = String.fromEnvironment(
    'MOCK_ATTENDANCE_LAT',
    defaultValue: '8.9806',
  );

  static const mockAttendanceLongitude = String.fromEnvironment(
    'MOCK_ATTENDANCE_LNG',
    defaultValue: '38.7578',
  );

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 20);

  static bool get isProduction => environment.toLowerCase() == 'production';
  static bool get isStaging => environment.toLowerCase() == 'staging';
  static bool get allowMockAttendanceLocation =>
      !isProduction && !isStaging && useMockAttendanceLocation;

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

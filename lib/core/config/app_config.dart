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

  static const socketBaseUrl = String.fromEnvironment(
    'SOCKET_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000',
  );

  static const enableFirebase = bool.fromEnvironment(
    'ENABLE_FIREBASE',
    defaultValue: false,
  );

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 20);

  static bool get isProduction => environment.toLowerCase() == 'production';
  static bool get isStaging => environment.toLowerCase() == 'staging';

  static void validate() {
    const valid = {'development', 'staging', 'production'};
    if (!valid.contains(environment.toLowerCase())) {
      throw StateError('Unsupported APP_ENV: $environment');
    }

    final api = Uri.tryParse(apiBaseUrl);
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

import 'package:flutter/foundation.dart';

/// Maps invite / custom-scheme URIs to an in-app go_router location.
String? employeeDeepLinkLocation(Uri? uri) {
  if (uri == null) return null;

  final isWorkforceScheme = uri.scheme == 'workforce';
  final path = uri.path;
  final host = uri.host;
  final isLogin = host == 'login' || path == '/login' || path.endsWith('/login') || path == 'login';

  if (isWorkforceScheme && isLogin) {
    return _loginLocation(uri);
  }

  // HTTPS web / universal-link style paths
  if ((uri.scheme == 'https' || uri.scheme == 'http') && isLogin) {
    return _loginLocation(uri);
  }

  // Path-only (some embeddings strip the scheme)
  if (path == '/login' || path.endsWith('/login')) {
    return _loginLocation(uri);
  }

  return null;
}

String _loginLocation(Uri uri) {
  final email = uri.queryParameters['email'] ?? uri.queryParameters['login'];
  if (email == null || email.trim().isEmpty) return '/login';
  return '/login?email=${Uri.encodeQueryComponent(email.trim())}';
}

bool get employeeDeepLinksSupported => !kIsWeb;

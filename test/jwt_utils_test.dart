import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:workforce_employee_app/core/auth/jwt_utils.dart';

String _jwtWithExp(int expSeconds) {
  final header = base64Url.encode(utf8.encode('{"alg":"none"}')).replaceAll('=', '');
  final payload = base64Url.encode(utf8.encode(jsonEncode({'exp': expSeconds}))).replaceAll('=', '');
  return '$header.$payload.sig';
}

void main() {
  test('accessTokenExpiresAt reads exp claim', () {
    final exp = DateTime.utc(2030, 1, 1).millisecondsSinceEpoch ~/ 1000;
    final at = accessTokenExpiresAt(_jwtWithExp(exp));
    expect(at, isNotNull);
    expect(at!.toUtc(), DateTime.utc(2030, 1, 1));
  });

  test('accessTokenExpiresAt returns null for garbage', () {
    expect(accessTokenExpiresAt('not-a-jwt'), isNull);
    expect(accessTokenExpiresAt('a.b'), isNull);
  });
}

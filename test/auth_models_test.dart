import 'package:flutter_test/flutter_test.dart';
import 'package:workforce_employee_app/features/auth/data/auth_models.dart';

void main() {
  test('parses auth session returned by backend', () {
    final session = AuthSession.fromJson({
      'accessToken': 'access',
      'refreshToken': 'refresh',
      'mustChangePassword': true,
      'user': {
        'id': 'user-1',
        'email': 'employee@example.com',
        'roles': ['EMPLOYEE'],
      },
    });

    expect(session.mustChangePassword, isTrue);
    expect(session.user.roles, ['EMPLOYEE']);
  });
}

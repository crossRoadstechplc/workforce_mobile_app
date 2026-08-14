class EmployeeProfile {
  const EmployeeProfile({
    required this.firstName,
    required this.lastName,
    required this.displayName,
    this.employeeCode,
  });

  final String firstName;
  final String lastName;
  final String displayName;
  final String? employeeCode;

  factory EmployeeProfile.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const EmployeeProfile(firstName: '', lastName: '', displayName: '');
    }
    final firstName = json['firstName']?.toString() ?? '';
    final lastName = json['lastName']?.toString() ?? '';
    final displayName = json['displayName']?.toString() ?? '';
    return EmployeeProfile(
      firstName: firstName,
      lastName: lastName,
      displayName: displayName.isNotEmpty ? displayName : firstName,
      employeeCode: json['employeeCode']?.toString(),
    );
  }
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.roles,
    this.employee,
  });

  final String id;
  final String email;
  final List<String> roles;
  final EmployeeProfile? employee;

  String get displayName {
    if (employee != null && employee!.displayName.isNotEmpty) return employee!.displayName;
    final prefix = email.split('@').first;
    return prefix.isNotEmpty ? prefix : email;
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        email: json['email'] as String,
        roles: (json['roles'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
        employee: EmployeeProfile.fromJson(json['employee'] as Map<String, dynamic>?),
      );
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.mustChangePassword,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final bool mustChangePassword;
  final AuthUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        mustChangePassword: json['mustChangePassword'] as bool? ?? false,
        user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      );
}

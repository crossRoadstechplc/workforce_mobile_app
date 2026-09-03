enum ContextType { platform, orgAdmin, officeAdmin, employee }

extension ContextTypeJson on ContextType {
  static ContextType fromJson(String value) => switch (value) {
        'platform' => ContextType.platform,
        'org_admin' => ContextType.orgAdmin,
        'office_admin' => ContextType.officeAdmin,
        'employee' => ContextType.employee,
        _ => ContextType.employee,
      };

  String get apiValue => switch (this) {
        ContextType.platform => 'platform',
        ContextType.orgAdmin => 'org_admin',
        ContextType.officeAdmin => 'office_admin',
        ContextType.employee => 'employee',
      };

  bool get isEmployee => this == ContextType.employee;
  bool get isAdmin => this == ContextType.platform || this == ContextType.orgAdmin || this == ContextType.officeAdmin;
}

class ActiveContext {
  const ActiveContext({
    required this.key,
    required this.type,
    this.organizationId,
    this.officeIds = const [],
  });

  final String key;
  final ContextType type;
  final String? organizationId;
  final List<String> officeIds;

  factory ActiveContext.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ActiveContext(key: 'legacy', type: ContextType.employee);
    }
    return ActiveContext(
      key: json['key']?.toString() ?? 'legacy',
      type: ContextTypeJson.fromJson(json['type']?.toString() ?? 'employee'),
      organizationId: json['organizationId']?.toString(),
      officeIds: (json['officeIds'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
    );
  }
}

class LoginContext {
  const LoginContext({
    required this.key,
    required this.type,
    required this.label,
    this.organizationId,
    this.organizationName,
    this.officeNames = const [],
  });

  final String key;
  final ContextType type;
  final String label;
  final String? organizationId;
  final String? organizationName;
  final List<String> officeNames;

  factory LoginContext.fromJson(Map<String, dynamic> json) => LoginContext(
        key: json['key'] as String,
        type: ContextTypeJson.fromJson(json['type'] as String),
        label: json['label'] as String,
        organizationId: json['organizationId']?.toString(),
        organizationName: json['organizationName']?.toString(),
        officeNames: (json['officeNames'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      );
}

List<LoginContext> employeeAppLoginContexts(List<LoginContext> contexts) {
  return contexts.where((item) => item.type.isEmployee).toList();
}

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
    this.activeContext,
    this.organizationName,
  });

  final String id;
  final String email;
  final List<String> roles;
  final EmployeeProfile? employee;
  final ActiveContext? activeContext;
  final String? organizationName;

  bool get isEmployeeContext => activeContext?.type.isEmployee ?? roles.contains('EMPLOYEE');

  String get displayName {
    if (employee != null && employee!.displayName.isNotEmpty) return employee!.displayName;
    final prefix = email.split('@').first;
    return prefix.isNotEmpty ? prefix : email;
  }

  String get contextLabel => activeContext != null
      ? switch (activeContext!.type) {
          ContextType.platform => 'Platform Admin',
          ContextType.orgAdmin => organizationName != null ? '$organizationName · Admin' : 'Company Admin',
          ContextType.officeAdmin => organizationName != null ? '$organizationName · Office Admin' : 'Office Admin',
          ContextType.employee => organizationName != null ? '$organizationName · Employee' : 'Employee',
        }
      : displayName;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final organization = json['organization'] as Map<String, dynamic>?;
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      roles: (json['roles'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      employee: EmployeeProfile.fromJson(json['employee'] as Map<String, dynamic>?),
      activeContext: ActiveContext.fromJson(json['activeContext'] as Map<String, dynamic>?),
      organizationName: organization?['name']?.toString(),
    );
  }
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.mustChangePassword,
    required this.user,
    this.activeContext,
  });

  final String accessToken;
  final String refreshToken;
  final bool mustChangePassword;
  final AuthUser user;
  final ActiveContext? activeContext;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        mustChangePassword: json['mustChangePassword'] as bool? ?? false,
        user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
        activeContext: ActiveContext.fromJson(json['activeContext'] as Map<String, dynamic>? ??
            (json['user'] as Map<String, dynamic>?)?['activeContext'] as Map<String, dynamic>?),
      );
}

class PendingLoginSelection {
  const PendingLoginSelection({
    required this.preAuthToken,
    required this.contexts,
    this.defaultContextKey,
  });

  final String preAuthToken;
  final List<LoginContext> contexts;
  final String? defaultContextKey;
}

class LoginResponse {
  const LoginResponse._({
    this.session,
    this.pending,
  });

  final AuthSession? session;
  final PendingLoginSelection? pending;

  bool get requiresContextSelection => pending != null;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    if (json['requiresContextSelection'] == true) {
      return LoginResponse._(
        pending: PendingLoginSelection(
          preAuthToken: json['preAuthToken'] as String,
          contexts: (json['contexts'] as List<dynamic>)
              .map((item) => LoginContext.fromJson(item as Map<String, dynamic>))
              .toList(),
          defaultContextKey: json['defaultContextKey']?.toString(),
        ),
      );
    }
    return LoginResponse._(session: AuthSession.fromJson(json));
  }
}

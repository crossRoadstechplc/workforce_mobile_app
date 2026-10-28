import 'package:dio/dio.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_exception.dart';
import '../../auth/data/auth_models.dart';

class EmployeeIdentity {
  const EmployeeIdentity({
    required this.id,
    required this.email,
    required this.roles,
    required this.permissions,
    this.employee,
  });

  final String id;
  final String email;
  final List<String> roles;
  final List<String> permissions;
  final EmployeeProfile? employee;

  String get displayName {
    if (employee != null && employee!.displayName.isNotEmpty) return employee!.displayName;
    final prefix = email.split('@').first;
    return prefix.isNotEmpty ? prefix : email;
  }

  factory EmployeeIdentity.fromJson(Map<String, dynamic> j) => EmployeeIdentity(
        id: j['id'] as String,
        email: j['email']?.toString() ?? '',
        roles: (j['roles'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
        permissions: (j['permissions'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
        employee: EmployeeProfile.fromJson(j['employee'] as Map<String, dynamic>?),
      );
}

class ProfileRepository {
  ProfileRepository(this._dio);
  final Dio _dio;

  Future<EmployeeIdentity> me() async {
    try {
      final r = await _dio.get<Map<String, dynamic>>(ApiEndpoints.me);
      return EmployeeIdentity.fromJson(r.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<EmergencyContact>> listEmergencyContacts() async {
    try {
      final r = await _dio.get<Map<String, dynamic>>(ApiEndpoints.emergencyContacts);
      final items = r.data?['items'] as List<dynamic>? ?? const [];
      return items
          .whereType<Map>()
          .map((item) => EmergencyContact.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<EmergencyContact> createEmergencyContact({
    required String name,
    required String phone,
    String? relation,
    String? relationOther,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'phone': phone,
        'relation': relation,
        'relationOther': relationOther,
      };
      final r = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.emergencyContacts,
        data: data,
      );
      return EmergencyContact.fromJson(r.data ?? const {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<EmergencyContact> updateEmergencyContact({
    required String contactId,
    required String name,
    required String phone,
    String? relation,
    String? relationOther,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'phone': phone,
        'relation': relation,
        'relationOther': relationOther,
      };
      final r = await _dio.patch<Map<String, dynamic>>(
        '${ApiEndpoints.emergencyContacts}/$contactId',
        data: data,
      );
      return EmergencyContact.fromJson(r.data ?? const {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> deleteEmergencyContact(String contactId) async {
    try {
      await _dio.delete('${ApiEndpoints.emergencyContacts}/$contactId');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

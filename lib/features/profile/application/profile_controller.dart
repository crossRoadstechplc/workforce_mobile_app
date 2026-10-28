import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../auth/application/session_controller.dart';
import '../../auth/data/auth_models.dart';
import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) => ProfileRepository(ref.watch(dioProvider)));
final profileControllerProvider = AsyncNotifierProvider<ProfileController, EmployeeIdentity>(ProfileController.new);

class ProfileController extends AsyncNotifier<EmployeeIdentity> {
  @override
  Future<EmployeeIdentity> build() async {
    final userId = ref.watch(sessionControllerProvider.select((s) => s.user?.id));
    if (userId == null) {
      throw StateError('Not authenticated');
    }
    return ref.read(profileRepositoryProvider).me();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => ref.read(profileRepositoryProvider).me());
  }

  Future<void> _setContacts(List<EmergencyContact> contacts) async {
    final current = state.value;
    if (current == null) {
      await refresh();
      return;
    }
    final employee = current.employee?.withEmergencyContacts(contacts) ??
        EmployeeProfile(
          firstName: '',
          lastName: '',
          displayName: current.displayName,
          emergencyContacts: contacts,
        );
    state = AsyncData(
      EmployeeIdentity(
        id: current.id,
        email: current.email,
        roles: current.roles,
        permissions: current.permissions,
        employee: employee,
      ),
    );
  }

  Future<void> addEmergencyContact({
    required String name,
    required String phone,
    String? relation,
    String? relationOther,
  }) async {
    await ref.read(profileRepositoryProvider).createEmergencyContact(
          name: name,
          phone: phone,
          relation: relation,
          relationOther: relationOther,
        );
    final contacts = await ref.read(profileRepositoryProvider).listEmergencyContacts();
    await _setContacts(contacts);
  }

  Future<void> updateEmergencyContact({
    required String contactId,
    required String name,
    required String phone,
    String? relation,
    String? relationOther,
  }) async {
    await ref.read(profileRepositoryProvider).updateEmergencyContact(
          contactId: contactId,
          name: name,
          phone: phone,
          relation: relation,
          relationOther: relationOther,
        );
    final contacts = await ref.read(profileRepositoryProvider).listEmergencyContacts();
    await _setContacts(contacts);
  }

  Future<void> deleteEmergencyContact(String contactId) async {
    await ref.read(profileRepositoryProvider).deleteEmergencyContact(contactId);
    final contacts = await ref.read(profileRepositoryProvider).listEmergencyContacts();
    await _setContacts(contacts);
  }
}

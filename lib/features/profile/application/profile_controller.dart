import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../auth/application/session_controller.dart';
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
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../data/profile_repository.dart';
final profileRepositoryProvider=Provider<ProfileRepository>((ref)=>ProfileRepository(ref.watch(dioProvider)));
final profileControllerProvider=AsyncNotifierProvider<ProfileController,EmployeeIdentity>(ProfileController.new);
class ProfileController extends AsyncNotifier<EmployeeIdentity>{@override Future<EmployeeIdentity> build()=>ref.read(profileRepositoryProvider).me();Future<void> refresh() async{state=await AsyncValue.guard(()=>ref.read(profileRepositoryProvider).me());}}

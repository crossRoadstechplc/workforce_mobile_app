import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../auth/application/session_controller.dart';
import '../data/evaluation_models.dart';
import '../data/evaluation_repository.dart';

final evaluationRepositoryProvider = Provider<EvaluationRepository>(
  (ref) => EvaluationRepository(ref.watch(dioProvider)),
);

final evaluationListControllerProvider =
    AsyncNotifierProvider<EvaluationListController, List<EvaluationSummary>>(EvaluationListController.new);

class EvaluationListController extends AsyncNotifier<List<EvaluationSummary>> {
  @override
  Future<List<EvaluationSummary>> build() async {
    final userId = ref.watch(sessionControllerProvider.select((s) => s.user?.id));
    if (userId == null) return const [];
    return ref.read(evaluationRepositoryProvider).list();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => ref.read(evaluationRepositoryProvider).list());
  }
}

final evaluationDetailProvider = FutureProvider.autoDispose.family<EvaluationDetail, String>((ref, id) {
  return ref.watch(evaluationRepositoryProvider).get(id);
});

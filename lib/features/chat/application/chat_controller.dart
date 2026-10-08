import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../auth/application/session_controller.dart';
import '../data/chat_models.dart';
import '../data/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) => ChatRepository(ref.watch(dioProvider)));

final chatListControllerProvider = AsyncNotifierProvider<ChatListController, ChatListData>(ChatListController.new);

class ChatListController extends AsyncNotifier<ChatListData> {
  Future<void>? _refreshInFlight;

  @override
  Future<ChatListData> build() async {
    final userId = ref.watch(sessionControllerProvider.select((s) => s.user?.id));
    if (userId == null) return const ChatListData();
    // Socket → provider updates are owned solely by RealtimeCoordinator.
    return ref.read(chatRepositoryProvider).conversations();
  }

  Future<void> refresh() {
    return _refreshInFlight ??= _doRefresh().whenComplete(() => _refreshInFlight = null);
  }

  Future<void> _doRefresh() async {
    state = await AsyncValue.guard(() => ref.read(chatRepositoryProvider).conversations());
  }
}

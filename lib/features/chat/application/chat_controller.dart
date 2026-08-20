import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/realtime/socket_service.dart';
import '../../auth/application/session_controller.dart';
import '../../notifications/application/notification_controller.dart';
import '../data/chat_models.dart';
import '../data/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) => ChatRepository(ref.watch(dioProvider)));

final chatListControllerProvider = AsyncNotifierProvider<ChatListController, ChatListData>(ChatListController.new);

class ChatListController extends AsyncNotifier<ChatListData> {
  StreamSubscription<SocketEvent>? _subscription;

  @override
  Future<ChatListData> build() async {
    final userId = ref.watch(sessionControllerProvider.select((s) => s.user?.id));
    if (userId == null) return const ChatListData();
    final socket = ref.read(socketServiceProvider);
    _subscription = socket.events.listen(_handleEvent);
    ref.onDispose(() => _subscription?.cancel());
    return ref.read(chatRepositoryProvider).conversations();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => ref.read(chatRepositoryProvider).conversations());
  }

  void _handleEvent(SocketEvent event) {
    if (event.name == 'chat.message.created') refresh();
  }
}

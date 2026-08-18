import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../auth/application/session_controller.dart';
import '../data/meeting_models.dart';
import '../data/meeting_repository.dart';

final meetingRepositoryProvider = Provider<MeetingRepository>((ref) => MeetingRepository(ref.watch(dioProvider)));

class MeetingState {
  const MeetingState({this.rooms = const [], this.bookings = const []});
  final List<MeetingRoom> rooms;
  final List<MeetingBooking> bookings;
}

final meetingControllerProvider = AsyncNotifierProvider<MeetingController, MeetingState>(MeetingController.new);

class MeetingController extends AsyncNotifier<MeetingState> {
  @override
  Future<MeetingState> build() async {
    final userId = ref.watch(sessionControllerProvider.select((s) => s.user?.id));
    if (userId == null) return const MeetingState();
    return _load();
  }

  Future<MeetingState> _load() async {
    final r = ref.read(meetingRepositoryProvider);
    final values = await Future.wait([r.rooms(), r.list()]);
    return MeetingState(rooms: values[0] as List<MeetingRoom>, bookings: values[1] as List<MeetingBooking>);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  Future<void> book({
    required String roomId,
    required String title,
    required DateTime startsAt,
    required DateTime endsAt,
    String? notes,
  }) async {
    await ref.read(meetingRepositoryProvider).book(roomId: roomId, title: title, startsAt: startsAt, endsAt: endsAt, notes: notes);
    await refresh();
  }

  Future<void> cancel(String id) async {
    await ref.read(meetingRepositoryProvider).cancel(id);
    await refresh();
  }
}

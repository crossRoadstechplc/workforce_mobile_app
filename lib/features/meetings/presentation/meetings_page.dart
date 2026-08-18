import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/status_chip.dart';
import '../application/meeting_controller.dart';
import '../data/meeting_models.dart';
import 'book_meeting_sheet.dart';

class MeetingsPage extends ConsumerWidget {
  const MeetingsPage({super.key});

  Future<void> _book(BuildContext context, WidgetRef ref, MeetingState state) async {
    final l10n = context.l10n;
    if (state.rooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pickRoom)));
      return;
    }
    final draft = await showBookMeetingSheet(
      context,
      state.rooms,
      (roomId, date) => ref.read(meetingRepositoryProvider).availability(roomId, date),
    );
    if (draft == null) return;
    try {
      await ref.read(meetingControllerProvider.notifier).book(
            roomId: draft.roomId,
            title: draft.title,
            startsAt: draft.startsAt,
            endsAt: draft.endsAt,
            notes: draft.notes,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.meetingBooked)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(meetingControllerProvider);
    final l10n = context.l10n;

    return Scaffold(
      floatingActionButton: async.value == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _book(context, ref, async.value!),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.bookMeeting),
            ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(
          message: e.toString(),
          onRetry: () => ref.read(meetingControllerProvider.notifier).refresh(),
        ),
        data: (state) => RefreshIndicator(
          onRefresh: () => ref.read(meetingControllerProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (state.bookings.isEmpty)
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: Text(l10n.noMeetingsYet, style: TextStyle(color: context.appColors.textSecondary)),
                    ),
                  ),
                )
              else
                ...state.bookings.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _Card(
                      item: b,
                      onCancel: b.canCancel
                          ? () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(l10n.confirmCancelMeeting),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
                                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.cancel)),
                                  ],
                                ),
                              );
                              if (ok == true) await ref.read(meetingControllerProvider.notifier).cancel(b.id);
                            }
                          : null,
                    ),
                  ),
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.item, this.onCancel});
  final MeetingBooking item;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.yMMMd().add_jm();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
              StatusChip(label: item.status, kind: item.status == 'BOOKED' ? StatusKind.success : StatusKind.neutral),
            ],
          ),
          const SizedBox(height: 6),
          Text('${item.roomName} · ${item.officeName}'),
          Text('${fmt.format(item.startsAt)} – ${DateFormat.jm().format(item.endsAt)}'),
          if (onCancel != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: onCancel, child: Text(context.l10n.cancel)),
            ),
        ],
      ),
    );
  }
}

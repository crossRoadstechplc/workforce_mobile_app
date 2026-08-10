import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/connectivity/network_status.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/status_chip.dart';
import '../../attendance/application/attendance_controller.dart';
import '../../attendance/data/attendance_models.dart';
import '../../attendance/presentation/check_out_sheet.dart';
import '../../attendance/presentation/late_reason_sheet.dart';
import '../../auth/application/session_controller.dart';
import '../../notifications/application/notification_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Timer? _clock;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _checkIn() async {
    if (ref.read(networkStatusProvider).value == false) {
      _message('Check-in needs an internet connection.');
      return;
    }
    try {
      final controller = ref.read(attendanceControllerProvider.notifier);
      final attempt = await controller.prepareCheckIn();
      if (!mounted) return;
      if (!attempt.preview.insideRadius) {
        _message(
          'You are outside the allowed office radius '
          '(${attempt.preview.distanceMeters.round()} m away). Move closer and try again.',
        );
        return;
      }

      LateReasonResult? reason;
      if (attempt.preview.requiresLateReason) {
        reason = await showLateReasonSheet(context, attempt.preview.lateMinutes);
        if (reason == null) {
          if (mounted) _message('Check-in cancelled. Add a late reason to continue.');
          return;
        }
      }

      final result = await controller.confirmCheckIn(
        attempt,
        lateReasonType: reason?.type,
        lateReasonDescription: reason?.description,
      );
      if (mounted) _message(_checkInToast(DateTime.now(), result));
    } catch (error) {
      if (mounted) _message(error.toString());
    }
  }

  Future<void> _checkOut() async {
    if (ref.read(networkStatusProvider).value == false) {
      _message('Checkout needs an internet connection.');
      return;
    }
    final description = await showCheckOutSheet(context);
    if (description == null) {
      if (mounted) _message('Checkout cancelled.');
      return;
    }
    if (!mounted) return;
    try {
      final result = await ref.read(attendanceControllerProvider.notifier).checkOut(description);
      if (mounted) _message(_checkOutToast(DateTime.now(), result.workedMinutes));
    } catch (error) {
      if (mounted) _message(error.toString());
    }
  }

  void _message(String value) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(value),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final attendance = ref.watch(attendanceControllerProvider);
    final notifications = ref.watch(notificationControllerProvider);
    final emailName = session.user?.email.split('@').first ?? 'Employee';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good ${_dayPart(_now)},', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w400)),
            Text(emailName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Notifications',
            child: IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
            icon: Badge(
              isLabelVisible: (notifications.value?.unreadCount ?? 0) > 0,
              label: Text('${notifications.value?.unreadCount ?? 0}'),
              child: const Icon(Icons.notifications_none_rounded),
            ),
          ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(attendanceControllerProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(DateFormat('EEEE, MMMM d').format(_now), style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 18),
            attendance.when(
              loading: () => const AttendanceCardSkeleton(),
              error: (error, _) => AppCard(child: AppErrorView(message: error.toString(), onRetry: () => ref.read(attendanceControllerProvider.notifier).refresh())),
              data: (value) => _AttendanceCard(
                timesheet: value.timesheet,
                busy: value.loading,
                onCheckIn: _checkIn,
                onCheckOut: _checkOut,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _MetricCard(icon: Icons.event_available_rounded, label: 'This month', value: 'History', onTap: () => context.go('/history'))),
                const SizedBox(width: 12),
                Expanded(child: _MetricCard(icon: Icons.beach_access_outlined, label: 'Leave', value: 'Requests', onTap: () => context.go('/leave'))),
              ],
            ),
            const SizedBox(height: 16),
            const AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  SizedBox(height: 10),
                  Text('Your attendance card above is always the source of truth for the current workday.', style: TextStyle(color: AppColors.textSecondary, height: 1.45)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.timesheet, required this.busy, required this.onCheckIn, required this.onCheckOut});
  final Timesheet? timesheet;
  final bool busy;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;

  @override
  Widget build(BuildContext context) {
    final open = timesheet?.isOpen == true;
    final completed = timesheet != null && !timesheet!.isOpen;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: Text("Today's attendance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
              StatusChip(
                label: open
                    ? (timesheet!.lateMinutes > 0 ? 'Late' : 'Checked in')
                    : completed
                        ? 'Completed'
                        : 'Not checked in',
                kind: open
                    ? (timesheet!.lateMinutes > 0 ? StatusKind.warning : StatusKind.success)
                    : completed
                        ? StatusKind.success
                        : StatusKind.neutral,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (open) ...[
            _InfoRow(label: 'Check-in', value: DateFormat('HH:mm').format(timesheet!.actualCheckIn)),
            if (timesheet!.scheduledCheckOut != null) _InfoRow(label: 'Scheduled out', value: DateFormat('HH:mm').format(timesheet!.scheduledCheckOut!)),
            _InfoRow(label: 'Late', value: timesheet!.lateMinutes == 0 ? 'On time' : '${timesheet!.lateMinutes} min'),
            const SizedBox(height: 20),
            Semantics(
              button: true,
              label: 'Check out of work',
              child: ElevatedButton.icon(
                onPressed: busy ? null : onCheckOut,
                icon: const Icon(Icons.logout_rounded),
                label: Text(busy ? 'Checking location...' : 'Check out'),
              ),
            ),
          ] else if (completed) ...[
            _InfoRow(label: 'Check-in', value: DateFormat('HH:mm').format(timesheet!.actualCheckIn)),
            if (timesheet!.actualCheckOut != null)
              _InfoRow(label: 'Check-out', value: DateFormat('HH:mm').format(timesheet!.actualCheckOut!)),
            _InfoRow(label: 'Worked', value: _duration(timesheet!.workedMinutes)),
            _InfoRow(label: 'Late', value: timesheet!.lateMinutes == 0 ? 'On time' : '${timesheet!.lateMinutes} min'),
            const SizedBox(height: 12),
            const Text(
              'You have already completed attendance for today.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ] else ...[
            const Text('Ready to start your workday?', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            Semantics(
              button: true,
              label: 'Check in to work',
              child: ElevatedButton.icon(
                onPressed: busy ? null : onCheckIn,
                icon: const Icon(Icons.login_rounded),
                label: Text(busy ? 'Checking location...' : 'Check in'),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'You can check in any time today. If you are late, you will be asked for a reason.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary))), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))]),
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.label, required this.value, required this.onTap});
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AppColors.primary), const SizedBox(height: 14), Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))]),
        ),
      );
}

String _duration(int minutes) => '${minutes ~/ 60}h ${minutes % 60}m';

String _dayPart(DateTime now) {
  if (now.hour < 12) return 'morning';
  if (now.hour < 17) return 'afternoon';
  return 'evening';
}

String _checkInToast(DateTime now, Timesheet result) {
  if (result.lateMinutes > 0) {
    return 'Checked in ${result.lateMinutes} min late. Thanks for sharing your reason — have a good ${_dayPart(now)}.';
  }
  switch (_dayPart(now)) {
    case 'morning':
      return 'Good morning! Check-in successful. Have a productive day.';
    case 'afternoon':
      return 'Good afternoon! Check-in successful. Keep up the good work.';
    default:
      return 'Good evening! Check-in successful. Thanks for starting your shift.';
  }
}

String _checkOutToast(DateTime now, int workedMinutes) {
  final worked = _duration(workedMinutes);
  switch (_dayPart(now)) {
    case 'morning':
      return 'Checked out. Good work this morning — you worked $worked.';
    case 'afternoon':
      return 'Checked out. Great work this afternoon — you worked $worked.';
    default:
      return 'Checked out. Great work today — you worked $worked. Rest well!';
  }
}

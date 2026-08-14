import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/connectivity/network_status.dart';
import '../../../core/localization/l10n_extensions.dart';
import '../../../core/location/geo_utils.dart';
import '../../../core/location/location_service.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../attendance/application/attendance_controller.dart';
import '../../attendance/data/attendance_models.dart';
import '../../attendance/presentation/attendance_map_view.dart';
import '../../attendance/presentation/attendance_photo_capture_modal.dart';
import '../../attendance/presentation/check_out_sheet.dart';
import '../../attendance/presentation/late_reason_sheet.dart';
import '../../attendance/presentation/time_clock_status_card.dart';
import '../../notifications/application/notification_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Timer? _ticker;
  Timer? _locationTimer;
  DateTime _now = DateTime.now();
  AttendanceLocation? _userLocation;
  bool _locating = true;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _refreshLocation();
    _locationTimer = Timer.periodic(const Duration(seconds: 12), (_) => _refreshLocation());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshLocation() async {
    setState(() => _locating = _userLocation == null);
    final location = await ref.read(locationServiceProvider).tryCapture();
    if (!mounted) return;
    setState(() {
      if (location != null) _userLocation = location;
      _locating = false;
    });
  }

  Future<void> _checkIn() async {
    final l10n = context.l10n;
    if (ref.read(networkStatusProvider).value == false) {
      _message(l10n.checkInNeedsInternet);
      return;
    }
    try {
      final controller = ref.read(attendanceControllerProvider.notifier);
      final attempt = await controller.prepareCheckIn();
      if (!mounted) return;
      setState(() => _userLocation = attempt.location);
      if (!attempt.preview.insideRadius) {
        _message(l10n.outsideRadius(attempt.preview.distanceMeters.round()));
        return;
      }

      LateReasonResult? reason;
      if (attempt.preview.requiresLateReason) {
        reason = await showLateReasonSheet(context, attempt.preview.lateMinutes);
        if (reason == null) {
          if (mounted) _message(l10n.checkInCancelled);
          return;
        }
      }

      if (!mounted) return;
      final photoOk = await showAttendancePhotoCapture(
        context,
        purpose: AttendancePhotoPurpose.checkIn,
      );
      if (photoOk != true) {
        if (mounted) _message(l10n.checkInCancelled);
        return;
      }

      final result = await controller.confirmCheckIn(
        attempt,
        lateReasonType: reason?.type,
        lateReasonDescription: reason?.description,
      );
      if (mounted) _message(_checkInToast(context, DateTime.now(), result));
    } catch (error) {
      if (mounted) _message(error.toString());
    }
  }

  Future<void> _checkOut() async {
    final l10n = context.l10n;
    if (ref.read(networkStatusProvider).value == false) {
      _message(l10n.checkoutNeedsInternet);
      return;
    }
    final current = ref.read(attendanceControllerProvider).value?.timesheet;
    final carriedOver = current?.isCarriedOverOpenShift == true;
    final description = await showCheckOutSheet(
      context,
      carriedOverShift: carriedOver,
      shiftWorkDate: current?.workDate ?? current?.actualCheckIn,
    );
    if (description == null) {
      if (mounted) _message(l10n.checkoutCancelled);
      return;
    }
    if (!mounted) return;

    final photoOk = await showAttendancePhotoCapture(
      context,
      purpose: AttendancePhotoPurpose.checkOut,
    );
    if (photoOk != true) {
      if (mounted) _message(l10n.checkoutCancelled);
      return;
    }

    try {
      final result = await ref.read(attendanceControllerProvider.notifier).checkOut(description);
      if (mounted) _message(_checkOutToast(context, result, carriedOver: carriedOver));
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
    final attendance = ref.watch(attendanceControllerProvider);
    final officeAsync = ref.watch(officeContextProvider);
    final notifications = ref.watch(notificationControllerProvider);
    final colors = context.appColors;

    ref.listen(officeContextProvider, (previous, next) {
      next.whenData((_) => _refreshLocation());
    });

    return Scaffold(
      backgroundColor: colors.background,
      body: attendance.when(
        loading: () => const Center(child: AttendanceCardSkeleton()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AppErrorView(
              message: error.toString(),
              onRetry: () => ref.read(attendanceControllerProvider.notifier).refresh(),
            ),
          ),
        ),
        data: (value) => officeAsync.when(
          loading: () => const Center(child: AttendanceCardSkeleton()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AppErrorView(
                message: error.toString(),
                onRetry: () => ref.invalidate(officeContextProvider),
              ),
            ),
          ),
          data: (office) => _TimeClockBody(
            office: office,
            timesheet: value.timesheet,
            busy: value.loading,
            userLocation: _userLocation,
            locating: _locating,
            now: _now,
            unreadNotifications: notifications.value?.unreadCount ?? 0,
            onRefresh: () async {
              await Future.wait([
                ref.read(attendanceControllerProvider.notifier).refresh(),
                _refreshLocation(),
              ]);
            },
            onCheckIn: _checkIn,
            onCheckOut: _checkOut,
            onOpenNotifications: () => context.push('/notifications'),
          ),
        ),
      ),
    );
  }
}

class _TimeClockBody extends StatelessWidget {
  const _TimeClockBody({
    required this.office,
    required this.timesheet,
    required this.busy,
    required this.userLocation,
    required this.locating,
    required this.now,
    required this.unreadNotifications,
    required this.onRefresh,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onOpenNotifications,
  });

  final OfficeContext office;
  final Timesheet? timesheet;
  final bool busy;
  final AttendanceLocation? userLocation;
  final bool locating;
  final DateTime now;
  final int unreadNotifications;
  final Future<void> Function() onRefresh;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final VoidCallback onOpenNotifications;

  LocationZoneStatus get _zoneStatus {
    if (userLocation == null) {
      return locating ? LocationZoneStatus.unknown : LocationZoneStatus.unknown;
    }
    final inside = GeoUtils.insideRadius(
      userLat: userLocation!.latitude,
      userLng: userLocation!.longitude,
      officeLat: office.latitude,
      officeLng: office.longitude,
      radiusMeters: office.allowedRadiusMeters.toDouble(),
    );
    return inside ? LocationZoneStatus.inside : LocationZoneStatus.outside;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final open = timesheet?.isOpen == true;
    final completed = timesheet != null && !timesheet!.isOpen;
    final distance = userLocation == null
        ? null
        : GeoUtils.distanceMeters(
            fromLat: userLocation!.latitude,
            fromLng: userLocation!.longitude,
            toLat: office.latitude,
            toLng: office.longitude,
          );
    final zone = _zoneStatus;
    final inside = zone == LocationZoneStatus.inside;
    final carriedOver = open && timesheet!.isCarriedOverOpenShift;
    final elapsed = open ? timesheet!.displayElapsedAt(now) : Duration.zero;
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    final canCheckIn = !open && !completed && inside && !busy;
    final showCheckIn = !open && !completed;
    final showCheckOut = open;

    return RefreshIndicator(
      onRefresh: onRefresh,
      edgeOffset: 0,
      child: Stack(
        children: [
          Positioned.fill(
            child: AttendanceMapView(
              office: office,
              userLocation: userLocation,
              insideRadius: inside || zone == LocationZoneStatus.unknown,
            ),
          ),
          Positioned(
            top: 8,
            left: 16,
            right: 16,
            child: TimeClockStatusCard(
              office: office,
              timesheet: timesheet,
              elapsed: elapsed,
              now: now,
              zoneStatus: zone,
              locating: locating,
              distanceMeters: distance,
              unreadNotifications: unreadNotifications,
              onOpenNotifications: onOpenNotifications,
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomSafe + 12,
            child: _ActionDock(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showCheckIn && zone == LocationZoneStatus.outside) ...[
                    Text(
                      l10n.moveInsideZone,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: colors.warning, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (showCheckIn)
                    SizedBox(
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: canCheckIn ? onCheckIn : null,
                        icon: busy
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: colors.surface),
                              )
                            : const Icon(Icons.login_rounded),
                        label: Text(busy ? l10n.checkingLocation : l10n.checkIn),
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.surface,
                          disabledBackgroundColor: colors.muted,
                          disabledForegroundColor: colors.textSecondary,
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  if (showCheckOut)
                    SizedBox(
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: busy ? null : onCheckOut,
                        icon: busy
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: colors.surface),
                              )
                            : const Icon(Icons.logout_rounded),
                        label: Text(busy ? l10n.checkingLocation : (carriedOver ? l10n.closeShift : l10n.checkOut)),
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.error,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: colors.muted,
                          disabledForegroundColor: colors.textSecondary,
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  if (completed)
                    Container(
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.successBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        l10n.attendanceCompleted,
                        style: TextStyle(color: colors.success, fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionDock extends StatelessWidget {
  const _ActionDock({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: isDark ? 0.95 : 0.98),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: child,
      ),
    );
  }
}

String _checkInToast(BuildContext context, DateTime now, Timesheet result) {
  final l10n = context.l10n;
  if (result.lateMinutes > 0) {
    return l10n.checkInLate(result.lateMinutes, _dayPartLabel(context, now));
  }
  switch (_dayPart(now)) {
    case 'morning':
      return l10n.checkInSuccessMorning;
    case 'afternoon':
      return l10n.checkInSuccessAfternoon;
    default:
      return l10n.checkInSuccessEvening;
  }
}

String _checkOutToast(BuildContext context, Timesheet result, {required bool carriedOver}) {
  final l10n = context.l10n;
  final worked = formatDurationMinutes(context, result.workedMinutes);
  if (carriedOver) {
    return l10n.previousShiftClosed(worked);
  }
  return l10n.checkoutSuccess(worked);
}

String _dayPart(DateTime now) {
  if (now.hour < 12) return 'morning';
  if (now.hour < 17) return 'afternoon';
  return 'evening';
}

String _dayPartLabel(BuildContext context, DateTime now) {
  final l10n = context.l10n;
  switch (_dayPart(now)) {
    case 'morning':
      return l10n.dayPartMorning;
    case 'afternoon':
      return l10n.dayPartAfternoon;
    default:
      return l10n.dayPartEvening;
  }
}

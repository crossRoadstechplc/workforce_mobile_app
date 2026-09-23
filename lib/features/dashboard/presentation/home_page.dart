import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/network_status.dart';
import '../../../core/localization/l10n_extensions.dart';
import '../../../core/location/geo_utils.dart';
import '../../../core/location/location_service.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../attendance/application/attendance_controller.dart';
import '../../attendance/application/location_preview_controller.dart';
import '../../attendance/data/attendance_models.dart';
import '../../attendance/presentation/attendance_map_view.dart';
import '../../attendance/presentation/attendance_photo_capture_modal.dart';
import '../../attendance/presentation/check_out_sheet.dart';
import '../../attendance/presentation/late_reason_sheet.dart';
import '../../attendance/presentation/time_clock_status_card.dart';
import '../../evaluation/presentation/evaluation_due_banner.dart';
import '../application/shell_refresh.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Timer? _ticker;
  DateTime _now = DateTime.now();
  bool _attendanceActionInFlight = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _checkIn() async {
    if (_attendanceActionInFlight) return;
    final l10n = context.l10n;
    if (ref.read(networkStatusProvider).value == false) {
      _message(l10n.checkInNeedsInternet);
      return;
    }

    setState(() => _attendanceActionInFlight = true);
    try {
      final controller = ref.read(attendanceControllerProvider.notifier);
      final attempt = await controller.prepareCheckIn();
      if (!mounted) return;
      if (!attempt.preview.insideRadius) {
        _message(l10n.outsideRadius(attempt.preview.distanceMeters.round()));
        return;
      }

      if (attempt.location != null) {
        ref.read(locationPreviewProvider.notifier).applyActionLocation(attempt.location!);
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
      final office = await controller.latestOfficeContext();
      if (!mounted) return;
      final photoUrl = await _capturePhotoIfRequired(office, AttendancePhotoPurpose.checkIn);
      if (photoUrl == null && office.photoRequired) {
        if (mounted) _message(l10n.checkInCancelled);
        return;
      }

      final result = await controller.confirmCheckIn(
        attempt,
        lateReasonType: reason?.type,
        lateReasonDescription: reason?.description,
        photoUrl: photoUrl,
      );
      if (mounted) _message(_checkInToast(context, DateTime.now(), result));
    } catch (error) {
      if (mounted) _message(error.toString());
    } finally {
      if (mounted) setState(() => _attendanceActionInFlight = false);
    }
  }

  Future<void> _checkOut() async {
    if (_attendanceActionInFlight) return;
    final l10n = context.l10n;
    if (ref.read(networkStatusProvider).value == false) {
      _message(l10n.checkoutNeedsInternet);
      return;
    }

    setState(() => _attendanceActionInFlight = true);
    try {
      final current = ref.read(attendanceControllerProvider).value?.timesheet;
      final carriedOver = current?.isCarriedOverOpenShift == true;
      final sheetResult = await showCheckOutSheet(
        context,
        carriedOverShift: carriedOver,
        shiftWorkDate: current?.workDate ?? current?.actualCheckIn,
      );
      if (sheetResult == null || sheetResult.cancelled) {
        if (mounted) _message(l10n.checkoutCancelled);
        return;
      }
      if (!mounted) return;

      AttendanceLocation? checkoutLocation;
      final office = await ref.read(attendanceControllerProvider.notifier).latestOfficeContext();
      if (!mounted) return;
      if (office.locationRequired) {
        checkoutLocation = (await ref.read(locationServiceProvider).captureForAction()).withFreshCapturedAt();
      }

      final photoUrl = await _capturePhotoIfRequired(office, AttendancePhotoPurpose.checkOut);
      if (photoUrl == null && office.photoRequired) {
        if (mounted) _message(l10n.checkoutCancelled);
        return;
      }

      final description = sheetResult.workDescription.trim();
      final result = await ref.read(attendanceControllerProvider.notifier).checkOut(
            workDescription: description.isEmpty ? null : description,
            photoUrl: photoUrl,
            location: checkoutLocation,
          );
      if (mounted) _message(_checkOutToast(context, result, carriedOver: carriedOver));
    } catch (error) {
      if (mounted) _message(error.toString());
    } finally {
      if (mounted) setState(() => _attendanceActionInFlight = false);
    }
  }

  Future<String?> _capturePhotoIfRequired(OfficeContext office, AttendancePhotoPurpose purpose) async {
    if (!office.photoRequired) return null;

    return showAttendancePhotoCapture(
      context,
      purpose: purpose,
      upload: (bytes, mimeType) => ref.read(attendanceControllerProvider.notifier).uploadAttendancePhoto(
            bytes: bytes,
            mimeType: mimeType,
            purpose: purpose == AttendancePhotoPurpose.checkIn ? 'CHECK_IN' : 'CHECK_OUT',
          ),
    );
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
    final locationPreview = ref.watch(locationPreviewProvider);
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: ResponsiveContent(
        maxWidth: 960,
        child: attendance.when(
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
          data: (office) {
            if (!office.assigned) {
              return _UnassignedWorkBody(
                message: office.message ?? 'No office or schedule has been assigned yet.',
                onRefresh: () => refreshTimeClock(ref),
              );
            }
            return _TimeClockBody(
              office: office,
              timesheet: value.timesheet,
              busy: value.loading || _attendanceActionInFlight,
              zoneStatus: locationPreview.zoneStatus,
              locationAccess: locationPreview.access,
              locating: locationPreview.locating,
              userLocation: locationPreview.location,
              now: _now,
              onRefresh: () => refreshTimeClock(ref),
              onCheckIn: _checkIn,
              onCheckOut: _checkOut,
              onLocationBannerTap: office.locationRequired && locationPreview.needsLocationAction
                  ? () => ref.read(locationPreviewProvider.notifier).requestAccessAndRefresh()
                  : null,
            );
          },
        ),
      ),
      ),
    );
  }
}

class _UnassignedWorkBody extends StatelessWidget {
  const _UnassignedWorkBody({required this.message, required this.onRefresh});

  final String message;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_off_outlined, size: 56, color: colors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    'Time clock unavailable',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                    textAlign: TextAlign.center,
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

class _TimeClockBody extends StatelessWidget {
  const _TimeClockBody({
    required this.office,
    required this.timesheet,
    required this.busy,
    required this.zoneStatus,
    required this.locationAccess,
    required this.locating,
    required this.userLocation,
    required this.now,
    required this.onRefresh,
    required this.onCheckIn,
    required this.onCheckOut,
    this.onLocationBannerTap,
  });

  final OfficeContext office;
  final Timesheet? timesheet;
  final bool busy;
  final LocationZoneStatus zoneStatus;
  final LocationAccess locationAccess;
  final bool locating;
  final AttendanceLocation? userLocation;
  final DateTime now;
  final Future<void> Function() onRefresh;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final VoidCallback? onLocationBannerTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final open = timesheet?.isOpen == true;
    final completed = timesheet != null && !timesheet!.isOpen;
    final distance = userLocation == null || office.latitude == null || office.longitude == null
        ? null
        : GeoUtils.distanceMeters(
            fromLat: userLocation!.latitude,
            fromLng: userLocation!.longitude,
            toLat: office.latitude!,
            toLng: office.longitude!,
          );
    final inside = zoneStatus == LocationZoneStatus.inside;
    final carriedOver = open && timesheet!.isCarriedOverOpenShift;
    final elapsed = open ? timesheet!.displayElapsedAt(now) : Duration.zero;
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final locationRequired = office.locationRequired;

    final canCheckIn = !open && !completed && !busy && (!locationRequired || inside);
    final showCheckIn = !open && !completed;
    final showCheckOut = open;

    return RefreshIndicator(
      onRefresh: onRefresh,
      edgeOffset: 0,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Stack(
              children: [
                Positioned.fill(
                  child: locationRequired
                      ? AttendanceMapView(
                          office: office,
                          userLocation: userLocation,
                          insideRadius: inside,
                        )
                      : ColoredBox(color: colors.background),
                ),
                Positioned(
                  top: 8,
                  left: 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const EvaluationDueBanner(),
                      const SizedBox(height: 8),
                      TimeClockStatusCard(
                    office: office,
                    timesheet: timesheet,
                    elapsed: elapsed,
                    now: now,
                    zoneStatus: zoneStatus,
                    locationAccess: locationAccess,
                    locating: locating,
                    distanceMeters: distance,
                    skipLocation: !locationRequired,
                    recommendedWorkMinutes: office.scheduledWorkMinutes,
                    onLocationBannerTap: onLocationBannerTap,
                  ),
                    ],
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
                        if (showCheckIn && locationRequired && zoneStatus == LocationZoneStatus.outside) ...[
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
                              label: Text(busy && locationRequired ? l10n.checkingLocation : l10n.checkIn),
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
                              label: Text(busy && locationRequired ? l10n.checkingLocation : (carriedOver ? l10n.closeShift : l10n.checkOut)),
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

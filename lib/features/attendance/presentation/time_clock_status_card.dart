import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/location/location_service.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../l10n/app_localizations.dart';
import '../data/attendance_models.dart';

class TimeClockStatusCard extends StatelessWidget {
  const TimeClockStatusCard({
    super.key,
    required this.office,
    required this.timesheet,
    required this.elapsed,
    required this.now,
    required this.zoneStatus,
    required this.distanceMeters,
    this.locationAccess = LocationAccess.granted,
    this.locating = false,
    this.skipLocation = false,
    this.unreadNotifications = 0,
    this.onOpenNotifications,
    this.onLocationBannerTap,
    this.recommendedWorkMinutes = 0,
  });

  final OfficeContext office;
  final Timesheet? timesheet;
  final Duration elapsed;
  final DateTime now;
  final LocationZoneStatus zoneStatus;
  final double? distanceMeters;
  final LocationAccess locationAccess;
  final bool locating;
  final bool skipLocation;
  final int unreadNotifications;
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onLocationBannerTap;
  final int recommendedWorkMinutes;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final open = timesheet?.isOpen == true;
    final completed = timesheet != null && !timesheet!.isOpen;
    final carriedOver = open && timesheet!.isCarriedOverOpenShift;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: isDark ? 0.94 : 0.97),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _headline(l10n, open: open, completed: completed, carriedOver: carriedOver),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                if (onOpenNotifications != null)
                  _NotificationIconButton(
                    unread: unreadNotifications,
                    onPressed: onOpenNotifications!,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              open ? _formatElapsed(elapsed) : DateFormat('h:mm a', locale.toString()).format(now),
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
                height: 1.05,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _StatusLine(open: open, completed: completed, carriedOver: carriedOver, timesheet: timesheet),
            if (timesheet != null || recommendedWorkMinutes > 0) ...[
              const SizedBox(height: 8),
              _WorkedSummary(
                timesheet: timesheet,
                open: open,
                elapsed: elapsed,
                l10n: l10n,
                recommendedWorkMinutes: recommendedWorkMinutes,
              ),
            ],
            if (carriedOver) ...[
              const SizedBox(height: 8),
              Text(
                l10n.openShiftFrom(_formatShiftDate(timesheet!.workDate ?? timesheet!.actualCheckIn, locale)),
                style: TextStyle(fontSize: 12, color: colors.warning, fontWeight: FontWeight.w500, height: 1.35),
              ),
            ],
            const SizedBox(height: 14),
            _LocationBanner(
              officeName: office.name ?? '',
              zoneStatus: zoneStatus,
              locationAccess: locationAccess,
              locating: locating,
              distanceMeters: distanceMeters,
              skipLocation: skipLocation,
              detail: _locationDetail(l10n, locale, open: open, completed: completed, carriedOver: carriedOver),
              onTap: onLocationBannerTap,
            ),
          ],
        ),
      ),
    );
  }

  String _headline(
    AppLocalizations l10n, {
    required bool open,
    required bool completed,
    required bool carriedOver,
  }) {
    if (carriedOver) return l10n.openShiftPending;
    if (open) return l10n.readyToCheckOut;
    if (completed) return l10n.shiftComplete;
    return l10n.readyToCheckIn;
  }

  String? _locationDetail(
    AppLocalizations l10n,
    Locale locale, {
    required bool open,
    required bool completed,
    required bool carriedOver,
  }) {
    if (open && timesheet != null) {
      return carriedOver
          ? l10n.checkedInOnAt(
              _formatShiftDate(timesheet!.actualCheckIn, locale),
              DateFormat('h:mm a', locale.toString()).format(timesheet!.actualCheckIn),
            )
          : l10n.checkedInAt(DateFormat('h:mm a', locale.toString()).format(timesheet!.actualCheckIn));
    }
    if (completed && timesheet?.actualCheckOut != null) {
      return l10n.timeRange(
        DateFormat('h:mm a', locale.toString()).format(timesheet!.actualCheckIn),
        DateFormat('h:mm a', locale.toString()).format(timesheet!.actualCheckOut!),
      );
    }
    return null;
  }

  String _formatShiftDate(DateTime value, Locale locale) => DateFormat('EEE, MMM d', locale.toString()).format(value);

  String _formatElapsed(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

class _LocationBanner extends StatelessWidget {
  const _LocationBanner({
    required this.officeName,
    required this.zoneStatus,
    required this.locationAccess,
    required this.locating,
    required this.distanceMeters,
    this.detail,
    this.skipLocation = false,
    this.onTap,
  });

  final String officeName;
  final LocationZoneStatus zoneStatus;
  final LocationAccess locationAccess;
  final bool locating;
  final double? distanceMeters;
  final String? detail;
  final bool skipLocation;
  final VoidCallback? onTap;

  String? _permissionHint(AppLocalizations l10n) {
    if (skipLocation) return null;
    return switch (locationAccess) {
      LocationAccess.permissionRequired => kIsWeb
          ? '${l10n.locationPermissionHint}\n${l10n.locationPermissionWebHint}'
          : l10n.locationPermissionHint,
      LocationAccess.permissionDeniedForever =>
        kIsWeb ? l10n.locationPermissionWebHint : l10n.locationPermissionBlockedHint,
      LocationAccess.servicesDisabled => l10n.locationServicesOffHint,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final permissionHint = _permissionHint(l10n);
    final needsPermission = permissionHint != null;

    final (Color tone, Color bg, IconData icon, String label) = skipLocation
        ? (colors.success, colors.successBg, Icons.desktop_windows_rounded, l10n.companyPcLocation)
        : needsPermission
            ? (
                colors.primary,
                colors.primary.withValues(alpha: 0.12),
                Icons.location_searching_rounded,
                l10n.locationTapToAllow,
              )
            : switch (zoneStatus) {
                LocationZoneStatus.inside => (
                    colors.success,
                    colors.successBg,
                    Icons.verified_rounded,
                    l10n.authorizedLocation,
                  ),
                LocationZoneStatus.outside => (
                    colors.warning,
                    colors.warningBg,
                    Icons.location_off_rounded,
                    l10n.outsideAuthorized,
                  ),
                LocationZoneStatus.unknown => (
                    colors.textSecondary,
                    colors.muted,
                    locating ? Icons.my_location_rounded : Icons.location_disabled_rounded,
                    locating ? l10n.locatingLocation : l10n.locationUnavailable,
                  ),
              };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: needsPermission ? Border.all(color: tone.withValues(alpha: 0.35)) : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: tone),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: tone)),
                    const SizedBox(height: 2),
                    Text(
                      officeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                    ),
                    if (permissionHint != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          permissionHint,
                          style: TextStyle(fontSize: 12, color: colors.textSecondary, height: 1.35),
                        ),
                      )
                    else if (!skipLocation && zoneStatus == LocationZoneStatus.outside && distanceMeters != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(l10n.metersAway(distanceMeters!.round()), style: TextStyle(fontSize: 12, color: tone)),
                      )
                    else if (skipLocation)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          detail ?? l10n.locationNotRequired,
                          style: TextStyle(fontSize: 12, color: colors.textSecondary),
                        ),
                      )
                    else if (detail != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(detail!, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                      )
                    else if (!skipLocation &&
                        zoneStatus == LocationZoneStatus.unknown &&
                        !locating &&
                        onTap != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          l10n.locationTapToAllow,
                          style: TextStyle(fontSize: 12, color: colors.textSecondary, height: 1.35),
                        ),
                      ),
                  ],
                ),
              ),
              if (onTap != null) Icon(Icons.chevron_right_rounded, size: 20, color: tone),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkedSummary extends StatelessWidget {
  const _WorkedSummary({
    required this.timesheet,
    required this.open,
    required this.elapsed,
    required this.l10n,
    required this.recommendedWorkMinutes,
  });
  final Timesheet? timesheet;
  final bool open;
  final Duration elapsed;
  final AppLocalizations l10n;
  final int recommendedWorkMinutes;

  int get _scheduledMinutes {
    final start = timesheet?.scheduledCheckIn;
    final end = timesheet?.scheduledCheckOut;
    if (start != null && end != null) {
      return end.difference(start).inMinutes.clamp(0, 24 * 60);
    }
    return recommendedWorkMinutes;
  }

  String _fmtMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final worked = timesheet == null ? 0 : (open ? elapsed.inMinutes : timesheet!.workedMinutes);
    final scheduled = _scheduledMinutes;
    if (scheduled <= 0 && worked <= 0) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        if (timesheet != null) _Chip(label: l10n.timeClockWorked(_fmtMinutes(worked)), colors: colors),
        if (scheduled > 0) _Chip(label: l10n.timeClockScheduled(_fmtMinutes(scheduled)), colors: colors),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.colors});
  final String label;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary)),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.open,
    required this.completed,
    required this.carriedOver,
    required this.timesheet,
  });

  final bool open;
  final bool completed;
  final bool carriedOver;
  final Timesheet? timesheet;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final (Color dot, String label) = switch ((open, completed, carriedOver, timesheet?.lateMinutes ?? 0)) {
      (true, _, true, _) => (colors.warning, l10n.openShiftPending),
      (true, _, _, int l) when l > 0 => (colors.warning, l10n.checkedInLate),
      (true, _, _, _) => (colors.success, l10n.checkedIn),
      (_, true, _, _) => (colors.success, l10n.attendanceCompleted),
      _ => (colors.textSecondary, l10n.notCheckedIn),
    };

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: dot)),
      ],
    );
  }
}

class _NotificationIconButton extends StatelessWidget {
  const _NotificationIconButton({required this.unread, required this.onPressed});
  final int unread;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return IconButton(
      tooltip: context.l10n.notificationsTooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications_outlined, size: 22, color: colors.textSecondary),
          if (unread > 0)
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                padding: unread > 9 ? const EdgeInsets.symmetric(horizontal: 4, vertical: 1) : EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: unread > 9 ? 16 : 8, minHeight: unread > 9 ? 16 : 8),
                decoration: BoxDecoration(
                  color: colors.error,
                  shape: unread > 9 ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: unread > 9 ? BorderRadius.circular(8) : null,
                  border: Border.all(color: colors.surface, width: 1.5),
                ),
                child: unread > 9
                    ? Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

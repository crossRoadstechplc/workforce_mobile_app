import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/location/geo_utils.dart';
import '../../../core/location/location_service.dart';
import '../../auth/application/session_controller.dart';
import 'attendance_controller.dart';

class LocationPreviewState {
  const LocationPreviewState({
    this.access = LocationAccess.permissionRequired,
    this.location,
    this.zoneStatus = LocationZoneStatus.unknown,
    this.locating = false,
  });

  final LocationAccess access;
  final AttendanceLocation? location;
  final LocationZoneStatus zoneStatus;
  final bool locating;

  static const initial = LocationPreviewState();

  bool get needsLocationAction =>
      access == LocationAccess.permissionDeniedForever ||
      access == LocationAccess.servicesDisabled ||
      (access == LocationAccess.granted &&
          zoneStatus == LocationZoneStatus.unknown &&
          !locating &&
          location == null);
}

final locationPreviewProvider =
    NotifierProvider<LocationPreviewController, LocationPreviewState>(LocationPreviewController.new);

class LocationPreviewController extends Notifier<LocationPreviewState> {
  bool _autoPromptAttempted = false;

  @override
  LocationPreviewState build() {
    ref.listen(officeContextProvider, (previous, next) {
      next.whenData((_) => refreshPreview());
    });
    ref.listen(sessionControllerProvider.select((s) => s.user?.id), (previous, next) {
      if (next != null && next != previous) {
        _autoPromptAttempted = false;
        refreshPreview();
      } else if (next == null) {
        _autoPromptAttempted = false;
        state = LocationPreviewState.initial;
      }
    });

    Future.microtask(refreshPreview);
    return LocationPreviewState.initial;
  }

  Future<void> refreshPreview() async {
    final userId = ref.read(sessionControllerProvider.select((s) => s.user?.id));
    if (userId == null) {
      state = LocationPreviewState.initial;
      return;
    }

    state = LocationPreviewState(
      access: state.access,
      location: state.location,
      zoneStatus: state.zoneStatus,
      locating: true,
    );

    final locationService = ref.read(locationServiceProvider);
    var access = await locationService.checkAccess();

    if (access == LocationAccess.permissionRequired && !_autoPromptAttempted) {
      _autoPromptAttempted = true;
      access = await locationService.requestAccess();
    }

    if (access != LocationAccess.granted) {
      state = LocationPreviewState(access: access);
      return;
    }

    await _applyPreviewFix(locationService);
  }

  Future<void> requestAccessAndRefresh() async {
    if (state.locating) return;

    if (state.access == LocationAccess.servicesDisabled) {
      await Geolocator.openLocationSettings();
      await refreshPreview();
      return;
    }

    if (state.access == LocationAccess.permissionDeniedForever) {
      await openAppSettings();
      await refreshPreview();
      return;
    }

    state = LocationPreviewState(
      access: state.access,
      location: state.location,
      zoneStatus: state.zoneStatus,
      locating: true,
    );

    final locationService = ref.read(locationServiceProvider);
    final access = await locationService.requestAccess();
    if (access != LocationAccess.granted) {
      state = LocationPreviewState(access: access);
      return;
    }

    await _applyPreviewFix(locationService);
  }

  Future<void> _applyPreviewFix(LocationService locationService) async {
    final office = ref.read(officeContextProvider).asData?.value;
    final fix = await locationService.preview();
    if (fix == null || office == null) {
      state = const LocationPreviewState(access: LocationAccess.granted);
      return;
    }

    final inside = GeoUtils.insideRadius(
      userLat: fix.latitude,
      userLng: fix.longitude,
      officeLat: office.latitude,
      officeLng: office.longitude,
      radiusMeters: office.allowedRadiusMeters.toDouble(),
    );

    state = LocationPreviewState(
      access: LocationAccess.granted,
      location: fix,
      zoneStatus: inside ? LocationZoneStatus.inside : LocationZoneStatus.outside,
    );
  }

  void applyActionLocation(AttendanceLocation location) {
    final office = ref.read(officeContextProvider).asData?.value;
    if (office == null) {
      state = LocationPreviewState(
        access: LocationAccess.granted,
        location: location,
      );
      return;
    }

    final inside = GeoUtils.insideRadius(
      userLat: location.latitude,
      userLng: location.longitude,
      officeLat: office.latitude,
      officeLng: office.longitude,
      radiusMeters: office.allowedRadiusMeters.toDouble(),
    );

    state = LocationPreviewState(
      access: LocationAccess.granted,
      location: location,
      zoneStatus: inside ? LocationZoneStatus.inside : LocationZoneStatus.outside,
    );
  }
}

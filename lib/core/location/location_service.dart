import 'package:geolocator/geolocator.dart';

import '../config/app_config.dart';

class LocationFailure implements Exception {
  const LocationFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

enum LocationAccess {
  granted,
  permissionRequired,
  permissionDeniedForever,
  servicesDisabled,
}

class AttendanceLocation {
  const AttendanceLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.capturedAt,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime capturedAt;

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracyMeters': accuracyMeters,
        'capturedAt': capturedAt.toUtc().toIso8601String(),
      };

  AttendanceLocation withFreshCapturedAt() {
    return AttendanceLocation(
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
      capturedAt: DateTime.now().toUtc(),
    );
  }
}

class LocationService {
  double? _mockLat;
  double? _mockLng;

  /// When mock GPS is enabled, pin to the employee's office so UI and API stay aligned.
  void setMockAnchor(double latitude, double longitude) {
    _mockLat = latitude;
    _mockLng = longitude;
  }

  void clearMockAnchor() {
    _mockLat = null;
    _mockLng = null;
  }

  AttendanceLocation _mockLocation() {
    return AttendanceLocation(
      latitude: _mockLat ?? double.parse(AppConfig.mockAttendanceLatitude),
      longitude: _mockLng ?? double.parse(AppConfig.mockAttendanceLongitude),
      accuracyMeters: 10,
      capturedAt: DateTime.now().toUtc(),
    );
  }

  /// Read-only access check — never prompts the user.
  Future<LocationAccess> checkAccess() async {
    if (AppConfig.allowMockAttendanceLocation) {
      return LocationAccess.granted;
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationAccess.servicesDisabled;
    }

    final permission = await Geolocator.checkPermission();
    return switch (permission) {
      LocationPermission.always || LocationPermission.whileInUse => LocationAccess.granted,
      LocationPermission.deniedForever => LocationAccess.permissionDeniedForever,
      _ => LocationAccess.permissionRequired,
    };
  }

  /// Prompts for when-in-use location permission (card tap / explicit user action).
  Future<LocationAccess> requestAccess() async {
    if (AppConfig.allowMockAttendanceLocation) {
      return LocationAccess.granted;
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationAccess.servicesDisabled;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return switch (permission) {
      LocationPermission.always || LocationPermission.whileInUse => LocationAccess.granted,
      LocationPermission.deniedForever => LocationAccess.permissionDeniedForever,
      _ => LocationAccess.permissionRequired,
    };
  }

  /// Map/card preview only — never prompts; uses last-known fix when available.
  Future<AttendanceLocation?> preview() async {
    if (AppConfig.allowMockAttendanceLocation) {
      return _mockLocation();
    }

    final access = await checkAccess();
    if (access != LocationAccess.granted) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return AttendanceLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        capturedAt: DateTime.now().toUtc(),
      );
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        return AttendanceLocation(
          latitude: last.latitude,
          longitude: last.longitude,
          accuracyMeters: last.accuracy,
          capturedAt: DateTime.now().toUtc(),
        );
      }
      return null;
    }
  }

  /// Check-in/out — prompts for permission and captures a high-accuracy fix.
  Future<AttendanceLocation> captureForAction() async {
    if (AppConfig.allowMockAttendanceLocation) {
      return _mockLocation();
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationFailure('Turn on Location Services and try again.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationFailure('Location permission is required to check in or out.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure('Location permission is blocked. Enable it in system settings.');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );

    return AttendanceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
      capturedAt: DateTime.now().toUtc(),
    );
  }
}

enum LocationZoneStatus { unknown, inside, outside }

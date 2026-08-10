import 'package:geolocator/geolocator.dart';

import '../config/app_config.dart';

class LocationFailure implements Exception {
  const LocationFailure(this.message);
  final String message;
  @override
  String toString() => message;
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
}

class LocationService {
  Future<AttendanceLocation> capture() async {
    if (AppConfig.allowMockAttendanceLocation) {
      return AttendanceLocation(
        latitude: double.parse(AppConfig.mockAttendanceLatitude),
        longitude: double.parse(AppConfig.mockAttendanceLongitude),
        accuracyMeters: 10,
        capturedAt: DateTime.now().toUtc(),
      );
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

    // Always stamp with "now" — browser GPS timestamps are often stale/wrong
    // and the API rejects locations older than 5 minutes.
    return AttendanceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
      capturedAt: DateTime.now().toUtc(),
    );
  }
}

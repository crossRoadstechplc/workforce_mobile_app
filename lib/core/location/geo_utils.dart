import 'dart:math' as math;

class GeoUtils {
  GeoUtils._();

  static double distanceMeters({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    const earthRadius = 6371000.0;
    final lat1 = _toRad(fromLat);
    final lat2 = _toRad(toLat);
    final dLat = _toRad(toLat - fromLat);
    final dLng = _toRad(toLng - fromLng);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static bool insideRadius({
    required double userLat,
    required double userLng,
    required double officeLat,
    required double officeLng,
    required double radiusMeters,
  }) {
    return distanceMeters(fromLat: userLat, fromLng: userLng, toLat: officeLat, toLng: officeLng) <= radiusMeters;
  }

  static double _toRad(double deg) => deg * math.pi / 180;
}

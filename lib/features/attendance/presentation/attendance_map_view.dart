import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/location/location_service.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../data/attendance_models.dart';

class AttendanceMapView extends StatelessWidget {
  const AttendanceMapView({
    super.key,
    required this.office,
    this.userLocation,
    required this.insideRadius,
  });

  final OfficeContext office;
  final AttendanceLocation? userLocation;
  final bool insideRadius;

  @override
  Widget build(BuildContext context) {
    // Map tiles stay light in dark app theme; overlay colors match the light map.
    const mapColors = AppColorsExtension.light;
    final officePoint = LatLng(office.latitude, office.longitude);
    final userPoint = userLocation == null ? null : LatLng(userLocation!.latitude, userLocation!.longitude);
    final center = userPoint ?? officePoint;
    final zoom = _zoomForRadius(office.allowedRadiusMeters);
    final zoneColor = insideRadius ? mapColors.success : mapColors.warning;

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
      ),
      children: [
        TileLayer(
          urlTemplate: mapColors.mapTileUrl,
          userAgentPackageName: 'com.workforce.employee_app',
        ),
        CircleLayer(
          circles: [
            CircleMarker(
              point: officePoint,
              radius: office.allowedRadiusMeters.toDouble(),
              useRadiusInMeter: true,
              color: zoneColor.withValues(alpha: 0.18),
              borderColor: zoneColor,
              borderStrokeWidth: 2.5,
            ),
          ],
        ),
        if (userPoint != null)
          MarkerLayer(
            markers: [
              Marker(
                point: userPoint,
                width: 28,
                height: 28,
                child: Container(
                  decoration: BoxDecoration(
                    color: mapColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: mapColors.primary.withValues(alpha: 0.35),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: officePoint,
              width: 36,
              height: 36,
              child: Icon(Icons.business_rounded, color: mapColors.textPrimary, size: 28),
            ),
          ],
        ),
      ],
    );
  }

  double _zoomForRadius(int meters) {
    if (meters <= 120) return 16.5;
    if (meters <= 200) return 16;
    if (meters <= 400) return 15.2;
    return 14.5;
  }
}

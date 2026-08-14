class CheckInPreview {
  const CheckInPreview({
    required this.insideRadius,
    required this.distanceMeters,
    required this.isLate,
    required this.lateMinutes,
    required this.requiresLateReason,
  });

  final bool insideRadius;
  final double distanceMeters;
  final bool isLate;
  final int lateMinutes;
  final bool requiresLateReason;

  factory CheckInPreview.fromJson(Map<String, dynamic> json) => CheckInPreview(
        insideRadius: json['insideRadius'] as bool? ?? false,
        distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0,
        isLate: json['isLate'] as bool? ?? false,
        lateMinutes: (json['lateMinutes'] as num?)?.toInt() ?? 0,
        requiresLateReason: json['requiresLateReason'] as bool? ?? false,
      );
}

class OfficeContext {
  const OfficeContext({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.allowedRadiusMeters,
    required this.maximumAccuracyMeters,
    required this.timezone,
    this.photoRequired = false,
  });

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int allowedRadiusMeters;
  final int maximumAccuracyMeters;
  final String timezone;
  final bool photoRequired;

  factory OfficeContext.fromJson(Map<String, dynamic> json) => OfficeContext(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Office',
        address: json['address'] as String? ?? '',
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        allowedRadiusMeters: (json['allowedRadiusMeters'] as num?)?.toInt() ?? 150,
        maximumAccuracyMeters: (json['maximumAccuracyMeters'] as num?)?.toInt() ?? 100,
        timezone: json['timezone'] as String? ?? 'UTC',
        photoRequired: json['photoRequired'] as bool? ?? false,
      );
}

class Timesheet {
  const Timesheet({
    required this.id,
    required this.status,
    required this.actualCheckIn,
    this.actualCheckOut,
    this.scheduledCheckIn,
    this.scheduledCheckOut,
    this.workDate,
    this.lateMinutes = 0,
    this.workedMinutes = 0,
    this.earlyCheckoutMinutes = 0,
    this.overtimeMinutes = 0,
    this.isOpen = false,
    this.isMissingCheckout = false,
    this.isCarriedOverOpenShift = false,
  });

  final String id;
  final String status;
  final DateTime actualCheckIn;
  final DateTime? actualCheckOut;
  final DateTime? scheduledCheckIn;
  final DateTime? scheduledCheckOut;
  final DateTime? workDate;
  final int lateMinutes;
  final int workedMinutes;
  final int earlyCheckoutMinutes;
  final int overtimeMinutes;
  final bool isOpen;
  final bool isMissingCheckout;
  final bool isCarriedOverOpenShift;

  Duration displayElapsedAt(DateTime now) {
    if (!isOpen) return Duration.zero;
    final raw = now.difference(actualCheckIn);
    if (!isCarriedOverOpenShift || scheduledCheckOut == null) return raw;
    final scheduledSpan = scheduledCheckOut!.difference(actualCheckIn);
    return raw > scheduledSpan ? scheduledSpan : raw;
  }

  factory Timesheet.fromJson(Map<String, dynamic> json) => Timesheet(
        id: json['id'] as String,
        status: json['status']?.toString() ?? 'UNKNOWN',
        actualCheckIn: DateTime.parse(json['actualCheckIn'] as String).toLocal(),
        actualCheckOut: json['actualCheckOut'] == null ? null : DateTime.parse(json['actualCheckOut'] as String).toLocal(),
        scheduledCheckIn: json['scheduledCheckIn'] == null ? null : DateTime.parse(json['scheduledCheckIn'] as String).toLocal(),
        scheduledCheckOut: json['scheduledCheckOut'] == null ? null : DateTime.parse(json['scheduledCheckOut'] as String).toLocal(),
        workDate: json['workDate'] == null ? null : DateTime.parse(json['workDate'] as String).toLocal(),
        lateMinutes: (json['lateMinutes'] as num?)?.toInt() ?? 0,
        workedMinutes: (json['workedMinutes'] as num?)?.toInt() ?? 0,
        earlyCheckoutMinutes: (json['earlyCheckoutMinutes'] as num?)?.toInt() ?? 0,
        overtimeMinutes: (json['overtimeMinutes'] as num?)?.toInt() ?? 0,
        isOpen: json['isOpen'] as bool? ?? false,
        isMissingCheckout: json['isMissingCheckout'] as bool? ?? false,
        isCarriedOverOpenShift: json['isCarriedOverOpenShift'] as bool? ?? false,
      );
}

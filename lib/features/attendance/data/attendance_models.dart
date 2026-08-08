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

class Timesheet {
  const Timesheet({
    required this.id,
    required this.status,
    required this.actualCheckIn,
    this.actualCheckOut,
    this.scheduledCheckIn,
    this.scheduledCheckOut,
    this.lateMinutes = 0,
    this.workedMinutes = 0,
    this.earlyCheckoutMinutes = 0,
    this.overtimeMinutes = 0,
    this.isOpen = false,
  });

  final String id;
  final String status;
  final DateTime actualCheckIn;
  final DateTime? actualCheckOut;
  final DateTime? scheduledCheckIn;
  final DateTime? scheduledCheckOut;
  final int lateMinutes;
  final int workedMinutes;
  final int earlyCheckoutMinutes;
  final int overtimeMinutes;
  final bool isOpen;

  factory Timesheet.fromJson(Map<String, dynamic> json) => Timesheet(
        id: json['id'] as String,
        status: json['status']?.toString() ?? 'UNKNOWN',
        actualCheckIn: DateTime.parse(json['actualCheckIn'] as String).toLocal(),
        actualCheckOut: json['actualCheckOut'] == null ? null : DateTime.parse(json['actualCheckOut'] as String).toLocal(),
        scheduledCheckIn: json['scheduledCheckIn'] == null ? null : DateTime.parse(json['scheduledCheckIn'] as String).toLocal(),
        scheduledCheckOut: json['scheduledCheckOut'] == null ? null : DateTime.parse(json['scheduledCheckOut'] as String).toLocal(),
        lateMinutes: (json['lateMinutes'] as num?)?.toInt() ?? 0,
        workedMinutes: (json['workedMinutes'] as num?)?.toInt() ?? 0,
        earlyCheckoutMinutes: (json['earlyCheckoutMinutes'] as num?)?.toInt() ?? 0,
        overtimeMinutes: (json['overtimeMinutes'] as num?)?.toInt() ?? 0,
        isOpen: json['isOpen'] as bool? ?? false,
      );
}

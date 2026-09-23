double parseLeaveDays(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String formatLeaveDays(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(value.abs() < 10 ? 2 : 1);
}

class LeaveType {
  const LeaveType({required this.id, required this.name, this.description, this.code, this.tracksBalance = false});
  final String id;
  final String name;
  final String? description;
  final String? code;
  final bool tracksBalance;

  factory LeaveType.fromJson(Map<String, dynamic> json) => LeaveType(
        id: json['id'] as String,
        name: json['name']?.toString() ?? 'Leave',
        description: json['description']?.toString(),
        code: json['code']?.toString(),
        tracksBalance: json['tracksBalance'] == true,
      );
}

class LeaveRequestItem {
  const LeaveRequestItem({
    required this.id,
    required this.leaveTypeName,
    required this.startDate,
    required this.endDate,
    required this.numberOfDays,
    required this.reason,
    required this.status,
    this.requestedAt,
    this.decisionReason,
  });
  final String id;
  final String leaveTypeName;
  final DateTime startDate;
  final DateTime endDate;
  final double numberOfDays;
  final String reason;
  final String status;
  final DateTime? requestedAt;
  final String? decisionReason;

  factory LeaveRequestItem.fromJson(Map<String, dynamic> json) {
    final decisions = json['decisions'] as List<dynamic>? ?? const [];
    final latestDecision = decisions.isEmpty ? null : decisions.first as Map<String, dynamic>;
    return LeaveRequestItem(
      id: json['id'] as String,
      leaveTypeName: (json['leaveType'] as Map<String, dynamic>?)?['name']?.toString() ?? 'Leave',
      startDate: DateTime.parse(json['startDate'] as String).toLocal(),
      endDate: DateTime.parse(json['endDate'] as String).toLocal(),
      numberOfDays: parseLeaveDays(json['numberOfDays']),
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      requestedAt: json['requestedAt'] == null ? null : DateTime.parse(json['requestedAt'] as String).toLocal(),
      decisionReason: latestDecision?['decisionReason']?.toString(),
    );
  }
}

class AnnualLeaveBucket {
  const AnnualLeaveBucket({
    required this.id,
    required this.periodStart,
    required this.periodEnd,
    required this.serviceYears,
    required this.granted,
    required this.used,
    required this.pending,
    required this.remaining,
    required this.expiresOn,
    required this.kind,
  });

  final String id;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int serviceYears;
  final double granted;
  final double used;
  final double pending;
  final double remaining;
  final DateTime expiresOn;
  final String kind;

  factory AnnualLeaveBucket.fromJson(Map<String, dynamic> json) => AnnualLeaveBucket(
        id: json['id'] as String,
        periodStart: DateTime.parse(json['periodStart'] as String),
        periodEnd: DateTime.parse(json['periodEnd'] as String),
        serviceYears: (json['serviceYears'] as num?)?.toInt() ?? 0,
        granted: parseLeaveDays(json['granted']),
        used: parseLeaveDays(json['used']),
        pending: parseLeaveDays(json['pending']),
        remaining: parseLeaveDays(json['remaining']),
        expiresOn: DateTime.parse(json['expiresOn'] as String),
        kind: json['kind']?.toString() ?? 'CURRENT',
      );
}

class AnnualLeaveBalance {
  const AnnualLeaveBalance({
    required this.hireDate,
    required this.asOf,
    required this.completedYears,
    required this.serviceMonthsThisYear,
    required this.currentYearGrant,
    required this.carriedIn,
    required this.entitledTotal,
    required this.used,
    required this.pending,
    required this.available,
    required this.nextAnniversary,
    required this.nextYearGrant,
    this.buckets = const [],
  });

  final DateTime hireDate;
  final DateTime asOf;
  final int completedYears;
  final int serviceMonthsThisYear;
  final double currentYearGrant;
  final double carriedIn;
  final double entitledTotal;
  final double used;
  final double pending;
  final double available;
  final DateTime nextAnniversary;
  final double nextYearGrant;
  final List<AnnualLeaveBucket> buckets;

  AnnualLeaveBucket? get oldestOpenCarry {
    final open = buckets.where((b) => b.kind != 'EXPIRED' && b.remaining > 0).toList()
      ..sort((a, b) => a.periodStart.compareTo(b.periodStart));
    return open.isEmpty ? null : open.first;
  }

  factory AnnualLeaveBalance.fromJson(Map<String, dynamic> json) => AnnualLeaveBalance(
        hireDate: DateTime.parse(json['hireDate'] as String),
        asOf: DateTime.parse(json['asOf'] as String),
        completedYears: (json['completedYears'] as num?)?.toInt() ?? 0,
        serviceMonthsThisYear: (json['serviceMonthsThisYear'] as num?)?.toInt() ?? 0,
        currentYearGrant: parseLeaveDays(json['currentYearGrant']),
        carriedIn: parseLeaveDays(json['carriedIn']),
        entitledTotal: parseLeaveDays(json['entitledTotal']),
        used: parseLeaveDays(json['used']),
        pending: parseLeaveDays(json['pending']),
        available: parseLeaveDays(json['available']),
        nextAnniversary: DateTime.parse(json['nextAnniversary'] as String),
        nextYearGrant: parseLeaveDays(json['nextYearGrant']),
        buckets: (json['buckets'] as List<dynamic>? ?? const [])
            .map((e) => AnnualLeaveBucket.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class LeaveSummary {
  const LeaveSummary({
    this.totalRequests = 0,
    this.pendingRequests = 0,
    this.approvedRequests = 0,
    this.rejectedRequests = 0,
    this.cancelledRequests = 0,
    this.approvedDays = 0,
    this.rejectedDays = 0,
    this.annualLeave,
  });
  final int totalRequests;
  final int pendingRequests;
  final int approvedRequests;
  final int rejectedRequests;
  final int cancelledRequests;
  final double approvedDays;
  final double rejectedDays;
  final AnnualLeaveBalance? annualLeave;

  factory LeaveSummary.fromJson(Map<String, dynamic> json) => LeaveSummary(
        totalRequests: (json['totalRequests'] as num?)?.toInt() ?? 0,
        pendingRequests: (json['pendingRequests'] as num?)?.toInt() ?? 0,
        approvedRequests: (json['approvedRequests'] as num?)?.toInt() ?? 0,
        rejectedRequests: (json['rejectedRequests'] as num?)?.toInt() ?? 0,
        cancelledRequests: (json['cancelledRequests'] as num?)?.toInt() ?? 0,
        approvedDays: parseLeaveDays(json['approvedDays']),
        rejectedDays: parseLeaveDays(json['rejectedDays']),
        annualLeave: json['annualLeave'] is Map<String, dynamic>
            ? AnnualLeaveBalance.fromJson(json['annualLeave'] as Map<String, dynamic>)
            : null,
      );
}

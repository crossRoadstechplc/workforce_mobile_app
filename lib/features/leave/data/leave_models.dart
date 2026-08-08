class LeaveType {
  const LeaveType({required this.id, required this.name, this.description});
  final String id;
  final String name;
  final String? description;
  factory LeaveType.fromJson(Map<String, dynamic> json) => LeaveType(id: json['id'] as String, name: json['name']?.toString() ?? 'Leave', description: json['description']?.toString());
}

class LeaveRequestItem {
  const LeaveRequestItem({required this.id, required this.leaveTypeName, required this.startDate, required this.endDate, required this.numberOfDays, required this.reason, required this.status, this.requestedAt, this.decisionReason});
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
      numberOfDays: json['numberOfDays'] is num ? (json['numberOfDays'] as num).toDouble() : double.tryParse(json['numberOfDays']?.toString() ?? '') ?? 0,
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      requestedAt: json['requestedAt'] == null ? null : DateTime.parse(json['requestedAt'] as String).toLocal(),
      decisionReason: latestDecision?['decisionReason']?.toString(),
    );
  }
}

class LeaveSummary {
  const LeaveSummary({this.totalRequests = 0, this.pendingRequests = 0, this.approvedRequests = 0, this.rejectedRequests = 0, this.cancelledRequests = 0, this.approvedDays = 0, this.rejectedDays = 0});
  final int totalRequests;
  final int pendingRequests;
  final int approvedRequests;
  final int rejectedRequests;
  final int cancelledRequests;
  final double approvedDays;
  final double rejectedDays;

  factory LeaveSummary.fromJson(Map<String, dynamic> json) => LeaveSummary(
    totalRequests: (json['totalRequests'] as num?)?.toInt() ?? 0,
    pendingRequests: (json['pendingRequests'] as num?)?.toInt() ?? 0,
    approvedRequests: (json['approvedRequests'] as num?)?.toInt() ?? 0,
    rejectedRequests: (json['rejectedRequests'] as num?)?.toInt() ?? 0,
    cancelledRequests: (json['cancelledRequests'] as num?)?.toInt() ?? 0,
    approvedDays: (json['approvedDays'] as num?)?.toDouble() ?? 0,
    rejectedDays: (json['rejectedDays'] as num?)?.toDouble() ?? 0,
  );
}

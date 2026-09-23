import '../../history/history_date_utils.dart';

class AttendanceCorrectionRequest {
  const AttendanceCorrectionRequest({
    required this.id,
    required this.workDate,
    required this.status,
    this.employeeNote,
    this.adminNote,
    this.reviewedAt,
    required this.createdAt,
  });

  final String id;
  final DateTime workDate;
  final String status;
  final String? employeeNote;
  final String? adminNote;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  factory AttendanceCorrectionRequest.fromJson(Map<String, dynamic> json) {
    return AttendanceCorrectionRequest(
      id: json['id'] as String,
      workDate: parseCalendarDate(json['workDate'] as String),
      status: json['status'] as String,
      employeeNote: json['employeeNote'] as String?,
      adminNote: json['adminNote'] as String?,
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

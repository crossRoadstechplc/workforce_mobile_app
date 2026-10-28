import 'attendance_correction_models.dart';

class AttendanceCorrectionSubmission {
  const AttendanceCorrectionSubmission({
    required this.submissionId,
    required this.status,
    required this.days,
    this.employeeNote,
    required this.createdAt,
  });

  final String submissionId;
  final String status;
  final List<AttendanceCorrectionRequest> days;
  final String? employeeNote;
  final DateTime createdAt;

  int get dayCount => days.length;

  DateTime get workDateFrom => days.first.workDate;

  DateTime get workDateTo => days.last.workDate;
}

String _aggregateStatus(List<String> statuses) {
  if (statuses.any((s) => s == 'PENDING')) return 'PENDING';
  if (statuses.every((s) => s == 'APPROVED')) return 'APPROVED';
  if (statuses.every((s) => s == 'REJECTED')) return 'REJECTED';
  if (statuses.every((s) => s == 'CANCELLED')) return 'CANCELLED';
  return 'PARTIAL';
}

List<AttendanceCorrectionSubmission> groupAttendanceCorrections(List<AttendanceCorrectionRequest> items) {
  final map = <String, List<AttendanceCorrectionRequest>>{};
  for (final item in items) {
    final key = item.submissionId ?? item.id;
    map.putIfAbsent(key, () => []).add(item);
  }

  final submissions = <AttendanceCorrectionSubmission>[];
  for (final entry in map.entries) {
    final days = [...entry.value]..sort((a, b) => a.workDate.compareTo(b.workDate));
    submissions.add(
      AttendanceCorrectionSubmission(
        submissionId: entry.key,
        status: _aggregateStatus(days.map((d) => d.status).toList()),
        days: days,
        employeeNote: () {
          for (final day in days) {
            final note = day.employeeNote;
            if (note != null && note.isNotEmpty) return note;
          }
          return null;
        }(),
        createdAt: days.map((d) => d.createdAt).reduce((a, b) => a.isBefore(b) ? a : b),
      ),
    );
  }

  submissions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return submissions;
}

int pendingCorrectionSubmissionCount(List<AttendanceCorrectionRequest> items) {
  final keys = <String>{};
  for (final item in items) {
    if (item.status == 'PENDING') {
      keys.add(item.submissionId ?? item.id);
    }
  }
  return keys.length;
}

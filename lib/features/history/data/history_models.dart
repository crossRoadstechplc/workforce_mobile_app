class PageMeta {
  const PageMeta({required this.page, required this.pageSize, required this.total, required this.totalPages});
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  factory PageMeta.fromJson(Map<String, dynamic> json) => PageMeta(
        page: (json['page'] as num?)?.toInt() ?? 1,
        pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
        total: (json['total'] as num?)?.toInt() ?? 0,
        totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      );
}

class TimesheetHistoryItem {
  const TimesheetHistoryItem({
    required this.id,
    required this.workDate,
    required this.status,
    this.actualCheckIn,
    this.actualCheckOut,
    this.workedMinutes = 0,
    this.lateMinutes = 0,
    this.earlyCheckoutMinutes = 0,
    this.overtimeMinutes = 0,
    this.isLate = false,
    this.isMissingCheckout = false,
    this.hasWorksheet = false,
  });

  final String id;
  final DateTime workDate;
  final String status;
  final DateTime? actualCheckIn;
  final DateTime? actualCheckOut;
  final int workedMinutes;
  final int lateMinutes;
  final int earlyCheckoutMinutes;
  final int overtimeMinutes;
  final bool isLate;
  final bool isMissingCheckout;
  final bool hasWorksheet;

  factory TimesheetHistoryItem.fromJson(Map<String, dynamic> json) => TimesheetHistoryItem(
        id: json['id'] as String,
        workDate: DateTime.parse(json['workDate'] as String).toLocal(),
        status: json['status']?.toString() ?? 'UNKNOWN',
        actualCheckIn: _date(json['actualCheckIn']),
        actualCheckOut: _date(json['actualCheckOut']),
        workedMinutes: (json['workedMinutes'] as num?)?.toInt() ?? 0,
        lateMinutes: (json['lateMinutes'] as num?)?.toInt() ?? 0,
        earlyCheckoutMinutes: (json['earlyCheckoutMinutes'] as num?)?.toInt() ?? 0,
        overtimeMinutes: (json['overtimeMinutes'] as num?)?.toInt() ?? 0,
        isLate: json['isLate'] as bool? ?? ((json['lateMinutes'] as num?)?.toInt() ?? 0) > 0,
        isMissingCheckout: json['isMissingCheckout'] as bool? ?? false,
        hasWorksheet: json['worksheet'] != null,
      );
}

class WorksheetHistoryItem {
  const WorksheetHistoryItem({
    required this.id,
    required this.workDate,
    required this.status,
    required this.description,
    this.submittedAt,
    this.workedMinutes = 0,
  });

  final String id;
  final DateTime workDate;
  final String status;
  final String description;
  final DateTime? submittedAt;
  final int workedMinutes;

  factory WorksheetHistoryItem.fromJson(Map<String, dynamic> json) => WorksheetHistoryItem(
        id: json['id'] as String,
        workDate: DateTime.parse(json['workDate'] as String).toLocal(),
        status: json['status']?.toString() ?? 'SUBMITTED',
        description: json['workDescription']?.toString() ?? '',
        submittedAt: _date(json['submittedAt']),
        workedMinutes: ((json['timesheet'] as Map<String, dynamic>?)?['workedMinutes'] as num?)?.toInt() ?? 0,
      );
}

DateTime? _date(dynamic value) => value == null ? null : DateTime.parse(value as String).toLocal();

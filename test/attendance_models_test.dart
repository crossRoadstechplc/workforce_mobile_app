import 'package:flutter_test/flutter_test.dart';
import 'package:workforce_employee_app/features/attendance/data/attendance_models.dart';

void main() {
  test('parses check-in preview', () {
    final preview = CheckInPreview.fromJson({
      'insideRadius': true,
      'distanceMeters': 44.2,
      'isLate': true,
      'lateMinutes': 12,
      'requiresLateReason': true,
    });

    expect(preview.insideRadius, isTrue);
    expect(preview.lateMinutes, 12);
    expect(preview.requiresLateReason, isTrue);
  });
}

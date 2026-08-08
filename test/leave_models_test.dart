import 'package:flutter_test/flutter_test.dart';
import 'package:workforce_employee_app/features/leave/data/leave_models.dart';

void main() {
  test('Leave summary parses backend response', () {
    final value = LeaveSummary.fromJson({'totalRequests': 8, 'pendingRequests': 1, 'approvedRequests': 5, 'rejectedRequests': 2, 'approvedDays': 12});
    expect(value.totalRequests, 8);
    expect(value.approvedDays, 12);
  });

  test('Leave request accepts decimal serialized as string', () {
    final value = LeaveRequestItem.fromJson({
      'id': 'leave-1', 'leaveType': {'name': 'Annual Leave'},
      'startDate': '2026-08-10T00:00:00.000Z', 'endDate': '2026-08-11T00:00:00.000Z',
      'numberOfDays': '2', 'reason': 'Family event', 'status': 'PENDING', 'decisions': []
    });
    expect(value.numberOfDays, 2);
  });
}

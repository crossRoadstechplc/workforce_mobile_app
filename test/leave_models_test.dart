import 'package:flutter_test/flutter_test.dart';
import 'package:workforce_employee_app/features/leave/data/leave_models.dart';

void main() {
  test('Leave summary parses annual leave balance', () {
    final value = LeaveSummary.fromJson({
      'totalRequests': 8,
      'pendingRequests': 1,
      'approvedRequests': 5,
      'rejectedRequests': 2,
      'approvedDays': 12,
      'annualLeave': {
        'hireDate': '2024-03-15',
        'asOf': '2026-03-16',
        'completedYears': 2,
        'serviceMonthsThisYear': 0,
        'currentYearGrant': 16,
        'carriedIn': 6,
        'entitledTotal': 22,
        'used': 10,
        'pending': 0,
        'available': 22,
        'nextAnniversary': '2027-03-15',
        'nextYearGrant': 17,
        'buckets': [
          {
            'id': 'b1',
            'periodStart': '2024-03-15',
            'periodEnd': '2025-03-14',
            'serviceYears': 0,
            'granted': 16,
            'used': 10,
            'pending': 0,
            'remaining': 6,
            'expiresOn': '2027-03-15',
            'kind': 'CARRY'
          }
        ]
      }
    });
    expect(value.annualLeave?.available, 22);
    expect(value.annualLeave?.carriedIn, 6);
    expect(value.annualLeave?.oldestOpenCarry?.remaining, 6);
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

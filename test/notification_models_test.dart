import 'package:flutter_test/flutter_test.dart';
import 'package:workforce_employee_app/features/notifications/data/notification_models.dart';

void main() {
  test('Notification parses unread state', () {
    final item = AppNotification.fromJson({'id':'n1','type':'LEAVE_APPROVED','title':'Leave approved','message':'Approved','isRead':false,'createdAt':'2026-08-08T05:00:00Z'});
    expect(item.isRead, isFalse);
    expect(item.type, 'LEAVE_APPROVED');
  });
}

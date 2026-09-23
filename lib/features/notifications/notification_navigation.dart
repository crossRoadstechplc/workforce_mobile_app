import 'data/notification_models.dart';

/// Returns a go_router location when this notification should open a screen.
String? notificationRoute(AppNotification item) {
  final type = item.type.toUpperCase();
  final entity = item.relatedEntityType;

  if (entity == 'Evaluation' && item.relatedEntityId != null) {
    return '/evaluations/${item.relatedEntityId}';
  }
  if (entity == 'MeetingBooking' || type.startsWith('MEETING_')) {
    return '/meetings';
  }
  if (entity == 'ChatConversation' && item.relatedEntityId != null) {
    return '/chat/${item.relatedEntityId}';
  }
  if (type.contains('CHAT') && item.relatedEntityId != null) {
    return '/chat/${item.relatedEntityId}';
  }

  if (entity == 'LeaveRequest' || type.startsWith('LEAVE_')) {
    return '/leave';
  }

  if (entity == 'AttendanceCorrectnessRequest' || type.contains('ATTENDANCE_CORRECTNESS')) {
    return '/leave';
  }

  if (entity == 'Worksheet' || type.contains('WORKSHEET')) {
    return '/history';
  }

  if (entity == 'Timesheet' ||
      type.contains('CHECK_IN') ||
      type.contains('CHECK_OUT') ||
      type.contains('MISSING_CHECKOUT') ||
      type == 'ATTENDANCE_CORRECTED') {
    return '/home';
  }

  if (type.contains('EVALUATION')) {
    if (item.relatedEntityId != null) return '/evaluations/${item.relatedEntityId}';
    return '/evaluations';
  }

  return null;
}

bool notificationIsActionable(AppNotification item) => notificationRoute(item) != null;

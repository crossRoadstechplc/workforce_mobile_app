class ApiEndpoints {
  ApiEndpoints._();

  static const login = '/auth/login';
  static const refresh = '/auth/refresh';
  static const changePassword = '/auth/change-password';
  static const logout = '/auth/logout';
  static const me = '/auth/me';

  static const currentAttendance = '/attendance/current';
  static const attendanceContext = '/attendance/context';
  static const checkInPreview = '/attendance/check-in/preview';
  static const checkIn = '/attendance/check-in';
  static const checkOut = '/attendance/check-out';
  static const attendancePhotos = '/attendance/photos';

  static const timesheets = '/timesheets';
  static const timesheetCalendar = '/timesheets/calendar';
  static const worksheets = '/worksheets';
  static const worksheetCalendar = '/worksheets/calendar';

  static const leaveRequests = '/leave-requests';
  static const leaveTypes = '/leave-requests/types';
  static const leaveSummary = '/leave-requests/summary';

  static const notifications = '/notifications';
  static const notificationReadAll = '/notifications/read-all';
  static const notificationDevices = '/notifications/devices';
}

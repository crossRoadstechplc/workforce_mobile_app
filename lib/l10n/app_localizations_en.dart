// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Work-Force';

  @override
  String greetingHi(String name) {
    return 'Hi, $name';
  }

  @override
  String get navTimeClock => 'Time Clock';

  @override
  String get navHistory => 'History';

  @override
  String get navLeave => 'Leave';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get navMeetings => 'Meetings';

  @override
  String get navPerformance => 'Performance';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navChat => 'Chat';

  @override
  String get drawerSectionWork => 'Work';

  @override
  String get drawerSectionWorkplace => 'Workplace';

  @override
  String get drawerSectionAccount => 'Account';

  @override
  String get openMenu => 'Menu';

  @override
  String get employeeWorkspace => 'Employee workspace';

  @override
  String get loginTitle => 'Work-Force';

  @override
  String get loginSubtitle =>
      'Employee sign in · use your work email or employee code.';

  @override
  String get emailOrCode => 'Email or employee code';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get historyTitle => 'History';

  @override
  String get tabTimesheet => 'Timesheet';

  @override
  String get tabWorksheet => 'Worksheet';

  @override
  String get noTimesheetDay => 'No timesheet for this day.';

  @override
  String get noWorksheetDay => 'No worksheet for this day.';

  @override
  String get noWorksheetNeedAttendance =>
      'No attendance for this day. Check in first, then you can add a worksheet.';

  @override
  String get worksheetAfterCheckout =>
      'Check in first, then you can add a worksheet for this day.';

  @override
  String get daysNeedingWorksheet => 'Days needing a worksheet';

  @override
  String get tapDayToAddWorksheet =>
      'Tap a day below to open it and add a worksheet.';

  @override
  String get existingWorksheets => 'Your worksheets';

  @override
  String get tapDayToEditWorksheet =>
      'Tap a day below to open and edit that worksheet.';

  @override
  String get checkIn => 'Check in';

  @override
  String get checkOut => 'Check out';

  @override
  String get closeShift => 'Close shift';

  @override
  String get checkingLocation => 'Checking location...';

  @override
  String get authorizedLocation => 'Authorized location';

  @override
  String get outsideAuthorized => 'Outside authorized area';

  @override
  String get locatingLocation => 'Getting your location...';

  @override
  String get locationUnavailable => 'Location unavailable';

  @override
  String get locationTapToAllow => 'Tap to allow location';

  @override
  String get locationPermissionHint =>
      'Location is required for check-in. Tap here and allow when your browser or device asks.';

  @override
  String get locationPermissionWebHint =>
      'If no prompt appears, allow location for this site in browser settings (lock icon → Site settings → Location), then tap here again.';

  @override
  String get locationPermissionBlockedHint =>
      'Location is blocked. Tap to open settings and allow access.';

  @override
  String get locationServicesOffHint =>
      'Location services are off. Tap to open settings and turn them on.';

  @override
  String get companyPcLocation => 'Company PC';

  @override
  String get locationNotRequired => 'Location is not required on this device';

  @override
  String get readyToCheckIn => 'Ready to check in';

  @override
  String get readyToCheckOut => 'Ready to check out';

  @override
  String get shiftInProgress => 'Shift in progress';

  @override
  String get shiftComplete => 'Shift complete';

  @override
  String get notCheckedIn => 'Not checked in';

  @override
  String get checkedIn => 'Checked in';

  @override
  String get checkedInLate => 'Checked in · Late';

  @override
  String get openShiftPending => 'Open shift pending checkout';

  @override
  String get attendanceCompleted => 'Attendance completed';

  @override
  String timeClockWorked(String duration) {
    return 'Worked $duration';
  }

  @override
  String timeClockScheduled(String duration) {
    return 'Recommended $duration';
  }

  @override
  String get done => 'Done';

  @override
  String openShiftFrom(String date) {
    return 'Open shift from $date. Check out below to start today.';
  }

  @override
  String checkedInAt(String time) {
    return 'Checked in at $time';
  }

  @override
  String checkedInOnAt(String date, String time) {
    return 'Checked in $date at $time';
  }

  @override
  String get moveInsideZone => 'Move inside the authorized zone to check in';

  @override
  String get checkInNeedsInternet => 'Check-in needs an internet connection.';

  @override
  String get checkoutNeedsInternet => 'Checkout needs an internet connection.';

  @override
  String get checkoutCancelled => 'Checkout cancelled.';

  @override
  String get checkInCancelled =>
      'Check-in cancelled. Add a late reason to continue.';

  @override
  String outsideRadius(int meters) {
    return 'You are outside the allowed office radius ($meters m away). Move closer and try again.';
  }

  @override
  String metersAway(int meters) {
    return '$meters m from office';
  }

  @override
  String metersAwayShort(int meters) {
    return '$meters m away';
  }

  @override
  String get checkInSuccessMorning =>
      'Good morning! Check-in successful. Have a productive day.';

  @override
  String get checkInSuccessAfternoon =>
      'Good afternoon! Check-in successful. Keep up the good work.';

  @override
  String get checkInSuccessEvening =>
      'Good evening! Check-in successful. Thanks for starting your shift.';

  @override
  String checkInLate(int minutes, String dayPart) {
    return 'Checked in $minutes min late. Thanks for sharing your reason — have a good $dayPart.';
  }

  @override
  String checkoutSuccess(String worked) {
    return 'Checked out successfully — you worked $worked.';
  }

  @override
  String previousShiftClosed(String worked) {
    return 'Previous shift closed ($worked recorded). You can check in for today now.';
  }

  @override
  String get dayPartMorning => 'morning';

  @override
  String get dayPartAfternoon => 'afternoon';

  @override
  String get dayPartEvening => 'evening';

  @override
  String get finishWorkday => 'Check out';

  @override
  String get closeOpenShift => 'Close open shift';

  @override
  String get checkoutDescribeToday =>
      'Describe what you worked on today before checking out.';

  @override
  String get checkoutDescribeTodayOptional =>
      'Optionally describe what you worked on today. You can skip and check out without a worksheet.';

  @override
  String checkoutCloseShiftHint(String date) {
    return 'This closes your shift from $date. You can check in for today afterward.';
  }

  @override
  String get workSummary => 'Work summary';

  @override
  String get workSummaryOptional => 'Work summary (optional)';

  @override
  String get workSummaryHint =>
      'e.g. Completed client onboarding and team standup...';

  @override
  String get workSummaryShiftHint =>
      'Summarize tasks completed during that shift...';

  @override
  String get worksheetOptionalHint =>
      'Leave blank to check out without a worksheet. You can add it later from History.';

  @override
  String get skipAndCheckOut => 'Skip & check out';

  @override
  String get skipAndCloseShift => 'Skip & close';

  @override
  String get readyToSubmit => 'Ready to submit';

  @override
  String minChars(int min, int current) {
    return 'Minimum $min characters · $current/$min';
  }

  @override
  String get addWorksheet => 'Add worksheet';

  @override
  String get editWorksheet => 'Edit worksheet';

  @override
  String get saveWorksheet => 'Save';

  @override
  String get worksheetSaved => 'Worksheet saved.';

  @override
  String get reviewed => 'Reviewed';

  @override
  String get cancel => 'Cancel';

  @override
  String lateCheckInTitle(int minutes) {
    return 'You are $minutes minute(s) late';
  }

  @override
  String get lateCheckInSubtitle =>
      'You can still check in any time today. Select a reason to continue.';

  @override
  String get continueCheckIn => 'Continue check-in';

  @override
  String get tellUsWhy => 'Tell us why';

  @override
  String get leaveTitle => 'Leave';

  @override
  String get profileTitle => 'Profile';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get changePassword => 'Change password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get update => 'Update';

  @override
  String get signOut => 'Sign out';

  @override
  String get passwordChanged => 'Password changed successfully.';

  @override
  String get passwordRules =>
      'Passwords must match and be at least 6 characters.';

  @override
  String get accountId => 'Account ID';

  @override
  String get role => 'Role';

  @override
  String get access => 'Access';

  @override
  String permissionsCount(int count) {
    return '$count permissions';
  }

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageAmharic => 'አማርኛ';

  @override
  String get languageEnglishShort => 'Eng';

  @override
  String get languageAmharicShort => 'ኣማ';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get preferences => 'Preferences';

  @override
  String get onTime => 'On time';

  @override
  String get late => 'Late';

  @override
  String get missingCheckout => 'Missing checkout';

  @override
  String get submitted => 'Submitted';

  @override
  String get checkInLabel => 'Check-in';

  @override
  String get checkOutLabel => 'Check-out';

  @override
  String get worked => 'Worked';

  @override
  String get lateMinutes => 'Late';

  @override
  String get earlyCheckout => 'Early checkout';

  @override
  String get overtime => 'Overtime';

  @override
  String get worksheetSubmitted => 'Worksheet submitted.';

  @override
  String workedDuration(String duration) {
    return 'Worked $duration';
  }

  @override
  String get retry => 'Retry';

  @override
  String get offlineMessage => 'You are offline. Some actions may not work.';

  @override
  String get approved => 'Approved';

  @override
  String get pending => 'Pending';

  @override
  String get rejected => 'Rejected';

  @override
  String get submitLeaveRequest => 'Submit request';

  @override
  String get splashLoading => 'Loading...';

  @override
  String get splashSubtitle =>
      'Clock in, track your hours, review your timesheet';

  @override
  String get offlineBannerDetail =>
      'Offline — history remains visible, but attendance actions need a connection.';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get connectionUnavailable => 'Connection unavailable';

  @override
  String get connectionRetryHint =>
      'Check your connection and try again. Your saved server data is not changed.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get leaveHistory => 'Leave history';

  @override
  String get noLeaveRequests => 'No leave requests yet.';

  @override
  String get requestLeave => 'Request leave';

  @override
  String get requestAttendanceCorrection => 'Request attendance correction';

  @override
  String get leaveVsCorrectionHint =>
      'Use leave when you were absent. Use attendance correction when you worked but check-in or check-out is missing or wrong. Corrections do not use your leave balance.';

  @override
  String get attendanceCorrectionHistory => 'Attendance corrections';

  @override
  String get noAttendanceCorrections => 'No correction requests yet.';

  @override
  String get attendanceCorrectionSubmitted => 'Correction request submitted.';

  @override
  String get attendanceCorrectionTitle => 'Attendance correction';

  @override
  String get attendanceCorrectionHint =>
      'Ask your admin to mark selected days as worked (full scheduled shift). Only use this if you were at work—not for days you were on leave.';

  @override
  String get attendanceCorrectionNoteLabel => 'Note (optional)';

  @override
  String get attendanceCorrectionNoteHint =>
      'e.g. Forgot to check in at the office';

  @override
  String get attendanceCorrectionDatesLabel => 'Dates';

  @override
  String get attendanceCorrectionAddDate => 'Add date';

  @override
  String get attendanceCorrectionPickDate =>
      'Add at least one past working day.';

  @override
  String get attendanceCorrectionSubmit => 'Submit correction';

  @override
  String get attendanceCorrectionDateBlocked =>
      'That date already has a pending or approved correction, or you were on leave.';

  @override
  String get attendanceCorrectionStatusPending => 'Pending';

  @override
  String get attendanceCorrectionStatusApproved => 'Approved';

  @override
  String get attendanceCorrectionStatusRejected => 'Rejected';

  @override
  String get leaveRequestSubmitted => 'Leave request submitted.';

  @override
  String get annualLeaveTitle => 'Annual leave';

  @override
  String get annualLeaveDaysAvailable => 'days available';

  @override
  String annualLeaveThisYear(String days) {
    return 'This year $days';
  }

  @override
  String annualLeaveCarried(String days) {
    return 'Carried $days';
  }

  @override
  String annualLeaveUsed(String days) {
    return 'Used $days';
  }

  @override
  String annualLeavePendingDays(String days) {
    return 'Pending $days';
  }

  @override
  String annualLeaveServiceYears(String years) {
    return '$years years of service';
  }

  @override
  String annualLeaveNextGrant(String days, String date) {
    return 'Next grant $days days on $date';
  }

  @override
  String annualLeaveProRata(String days, String months) {
    return 'Pro-rata: $days of 16 days ($months months of service)';
  }

  @override
  String annualLeaveExpires(String days, String date) {
    return '$days days expire on $date';
  }

  @override
  String get annualLeaveBreakdown => 'Leave years';

  @override
  String annualLeaveAvailableHint(String days) {
    return '$days annual leave days remaining. Oldest carried days are used first.';
  }

  @override
  String get leaveTypeLabel => 'Leave type';

  @override
  String get leaveStartDate => 'Start date';

  @override
  String get leaveEndDate => 'End date';

  @override
  String get leaveReason => 'Reason';

  @override
  String get leaveReasonHint => 'Briefly explain your leave request';

  @override
  String get leavePastDatesHint =>
      'Past dates are allowed for missing attendance days. Days are counted from your work schedule (half days count as 0.5).';

  @override
  String get cancelRequest => 'Cancel request';

  @override
  String adminNote(String note) {
    return 'Admin: $note';
  }

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String get accountCreatedByAdmin =>
      'Your account is created by your administrator.';

  @override
  String get refresh => 'Refresh';

  @override
  String get enterEmailOrCode => 'Enter your email or employee code';

  @override
  String get passwordMin8 => 'Password must be at least 6 characters';

  @override
  String get thatDay => 'that day';

  @override
  String get reasonTraffic => 'Traffic';

  @override
  String get reasonTransportation => 'Transportation';

  @override
  String get reasonHealth => 'Health';

  @override
  String get reasonFamilyEmergency => 'Family emergency';

  @override
  String get reasonWeather => 'Weather';

  @override
  String get reasonOther => 'Other';

  @override
  String timeRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String daysCount(String start, String end, String days) {
    return '$start – $end • $days day(s)';
  }

  @override
  String lateMinutesValue(int minutes) {
    return '$minutes min';
  }

  @override
  String earlyCheckoutMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String overtimeMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get dash => '—';

  @override
  String get readAll => 'Read all';

  @override
  String get noNotificationsYet => 'No notifications yet.';

  @override
  String get notificationTapToOpen => 'Tap to open';

  @override
  String get notificationNoLinkedScreen =>
      'No linked screen for this alert. Try Leave or History from the menu.';

  @override
  String get photoCaptureTitleCheckIn => 'Verify check-in';

  @override
  String get photoCaptureTitleCheckOut => 'Verify checkout';

  @override
  String get photoCaptureHint => 'Position your face inside the circle';

  @override
  String get photoCaptureButton => 'Capture photo';

  @override
  String get photoRetake => 'Retake';

  @override
  String get photoUse => 'Use photo';

  @override
  String get photoUploading => 'Uploading photo...';

  @override
  String get photoCaptureFailed => 'Could not capture photo. Try again.';

  @override
  String get photoCameraPermissionRequired =>
      'Camera access is required to take your verification photo. Allow camera permission and try again.';

  @override
  String get photoCameraPermissionWeb =>
      'Camera access is required. Allow the camera for this site in your browser settings, then try again.';

  @override
  String get photoOpenSettings => 'Open settings';

  @override
  String get evaluationsTitle => 'Evaluations';

  @override
  String get noEvaluationsYet => 'No reviews yet.';

  @override
  String evaluationDue(String date) {
    return 'Due $date';
  }

  @override
  String evaluationSelfAverage(String value) {
    return 'Self total: $value';
  }

  @override
  String evaluationDueCard(String name) {
    return 'Complete your $name review';
  }

  @override
  String get evaluationStatusOpen => 'Action needed';

  @override
  String get evaluationStatusWaiting => 'With reviewer';

  @override
  String get evaluationStatusScored => 'Scored';

  @override
  String get evaluationStatusFinal => 'Final';

  @override
  String get evaluationStatusClosed => 'Closed';

  @override
  String get evaluationCycleClosedBanner =>
      'This evaluation cycle is closed. Your results are shown below.';

  @override
  String evaluationEvaluatorTotal(String value) {
    return 'Evaluator total: $value';
  }

  @override
  String get evaluationStepInfo => 'Employee information';

  @override
  String get evaluationStepMetrics => 'Metrics';

  @override
  String get evaluationStepRoles => 'Roles & responsibilities';

  @override
  String get evaluationStepSkills => 'Skills improved';

  @override
  String get evaluationStepGoals => 'Development goals';

  @override
  String get evaluationStepReview => 'Review & submit';

  @override
  String get evaluationEmployee => 'Name';

  @override
  String get evaluationPosition => 'Position';

  @override
  String get evaluationSupervisor => 'Direct supervisor';

  @override
  String get evaluationPeriod => 'Period';

  @override
  String get evaluationNumber => 'Number';

  @override
  String evaluationPrevious(String value) {
    return 'Previous: $value';
  }

  @override
  String get evaluationPickDate => 'Pick target date';

  @override
  String get evaluationCriteria => 'Evaluation criteria';

  @override
  String get evaluationReviewHint =>
      'Check your scores, then submit. You cannot change self-scores after submitting.';

  @override
  String get evaluationFocus => 'Focus competency';

  @override
  String get evaluationActionPlan => 'Action plan';

  @override
  String evaluationEvaluatorScore(String value) {
    return 'Evaluator: $value';
  }

  @override
  String get evaluationSubmit => 'Submit self-evaluation';

  @override
  String get evaluationSubmitConfirm =>
      'Submit your scores to your reviewer? You will not be able to edit them afterwards.';

  @override
  String get evaluationSubmitted => 'Self-evaluation submitted.';

  @override
  String get evaluationIncomplete =>
      'Rate every area from 1 to 5. Attendance is scored automatically.';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get meetingsTitle => 'Meetings';

  @override
  String get bookMeeting => 'Book room';

  @override
  String get noMeetingsYet => 'No bookings yet.';

  @override
  String get meetingBooked => 'Room booked.';

  @override
  String get meetingCancelled => 'Booking cancelled.';

  @override
  String get meetingRoom => 'Room';

  @override
  String get meetingTitle => 'Title';

  @override
  String get meetingNotes => 'Notes (optional)';

  @override
  String get meetingStart => 'Start';

  @override
  String get meetingEnd => 'End';

  @override
  String get meetingBusy => 'Already booked';

  @override
  String get pickRoom => 'Select a room';

  @override
  String get confirmCancelMeeting => 'Cancel this booking?';

  @override
  String get newChat => 'New chat';

  @override
  String get noChatsYet => 'No conversations yet.';

  @override
  String get noChatsHint => 'Start a private chat with a colleague.';

  @override
  String get searchColleagues => 'Search colleagues';

  @override
  String get noColleaguesFound => 'No colleagues found.';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get sayHello => 'Say hello to start the conversation.';

  @override
  String get messageHint => 'Message';

  @override
  String get contextPickerTitle => 'How are you signing in?';

  @override
  String get contextPickerSubtitle =>
      'Your account can sign in as more than one role. Choose Employee to use this app.';

  @override
  String get contextSuggested => 'Suggested';

  @override
  String get switchContext => 'Switch role';

  @override
  String get switchToEmployee => 'Use employee';

  @override
  String nonEmployeeContextBanner(String role) {
    return 'Signed in as $role. Employee features like check-in need the Employee role.';
  }

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get updateRequiredTitle => 'Update required';

  @override
  String get updateRequiredBody =>
      'This version is no longer supported. Please update the app to continue.';

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String get updateAvailableBody =>
      'A newer version is ready. You can update now or later from the menu.';

  @override
  String get updateNow => 'Update now';

  @override
  String get updateLater => 'Later';

  @override
  String get updateOpenFailed => 'Could not open the download page.';

  @override
  String currentVersion(String version) {
    return 'Current version: $version';
  }

  @override
  String latestVersion(String version) {
    return 'Latest version: $version';
  }

  @override
  String appVersionLabel(String version) {
    return 'Work-Force v$version';
  }
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Workforce';

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
  String get loginTitle => 'Employee sign in';

  @override
  String get loginSubtitle => 'Use your work email or employee code.';

  @override
  String get emailOrCode => 'Email or employee code';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get demoLoginHint => 'Demo: sara@acme.demo / Demo123!';

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
  String checkoutCloseShiftHint(String date) {
    return 'This closes your shift from $date. You can check in for today afterward.';
  }

  @override
  String get workSummary => 'Work summary';

  @override
  String get workSummaryHint =>
      'e.g. Completed client onboarding and team standup...';

  @override
  String get workSummaryShiftHint =>
      'Summarize tasks completed during that shift...';

  @override
  String get readyToSubmit => 'Ready to submit';

  @override
  String minChars(int min, int current) {
    return 'Minimum $min characters · $current/$min';
  }

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
      'Passwords must match, be 10+ characters, and include upper/lowercase letters and a number.';

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
  String get leaveRequestSubmitted => 'Leave request submitted.';

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
  String get demoLoginTitle => 'Demo login';

  @override
  String get demoEmailLabel => 'Email: sara@acme.demo';

  @override
  String get demoPasswordLabel => 'Password: Demo123!';

  @override
  String get demoEmailField => 'Email';

  @override
  String get demoPasswordField => 'Password';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get refresh => 'Refresh';

  @override
  String get demoLoginNote =>
      'Use Demo123! for seeded employees. ChangeMe123! is only for bootstrap super admin in admin portal.';

  @override
  String get enterEmailOrCode => 'Enter your email or employee code';

  @override
  String get passwordMin8 => 'Password must contain at least 8 characters';

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
  String evaluationDue(String date) => 'Due $date';
  @override
  String evaluationSelfAverage(String value) => 'Self average: $value';
  @override
  String evaluationDueCard(String name) => 'Complete your $name review';
  @override
  String get evaluationStatusOpen => 'Action needed';
  @override
  String get evaluationStatusWaiting => 'With reviewer';
  @override
  String get evaluationStatusScored => 'Scored';
  @override
  String get evaluationStatusFinal => 'Final';
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
  String evaluationPrevious(String value) => 'Previous: $value';
  @override
  String get evaluationPickDate => 'Pick target date';
  @override
  String get evaluationCriteria => 'Evaluation criteria';
  @override
  String get evaluationReviewHint => 'Check your scores, then submit. You cannot change self-scores after submitting.';
  @override
  String get evaluationFocus => 'Focus competency';
  @override
  String get evaluationActionPlan => 'Action plan';
  @override
  String evaluationEvaluatorScore(String value) => 'Evaluator: $value';
  @override
  String get evaluationSubmit => 'Submit self-evaluation';
  @override
  String get evaluationSubmitConfirm => 'Submit your scores to your reviewer? You will not be able to edit them afterwards.';
  @override
  String get evaluationSubmitted => 'Self-evaluation submitted.';
  @override
  String get evaluationIncomplete => 'Score every metric and responsibility item from 1 to 10.';
  @override
  String get back => 'Back';
  @override
  String get next => 'Next';
}

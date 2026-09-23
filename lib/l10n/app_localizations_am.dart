// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appTitle => 'የሰው ሀብት';

  @override
  String greetingHi(String name) {
    return 'ሰላም, $name';
  }

  @override
  String get navTimeClock => 'የጊዜ ሰዓት';

  @override
  String get navHistory => 'ታሪክ';

  @override
  String get navLeave => 'ፍቃድ';

  @override
  String get navProfile => 'መገለጫ';

  @override
  String get navSettings => 'ቅንብሮች';

  @override
  String get navMeetings => 'ስብሰባዎች';

  @override
  String get navPerformance => 'አፈጻጸም';

  @override
  String get navNotifications => 'ማሳወቂያዎች';

  @override
  String get navChat => 'ውይይት';

  @override
  String get drawerSectionWork => 'ስራ';

  @override
  String get drawerSectionWorkplace => 'የስራ ቦታ';

  @override
  String get drawerSectionAccount => 'መለያ';

  @override
  String get openMenu => 'ምናሌ';

  @override
  String get employeeWorkspace => 'የሰራተኛ መስሪያ';

  @override
  String get loginTitle => 'የሰራተኛ መግቢያ';

  @override
  String get loginSubtitle => 'የስራ ኢሜይል ወይም የሰራተኛ ኮድ ይጠቀሙ።';

  @override
  String get emailOrCode => 'ኢሜይል ወይም የሰራተኛ ኮድ';

  @override
  String get password => 'የይለፍ ቃል';

  @override
  String get signIn => 'ግባ';

  @override
  String get signingIn => 'በመግባት ላይ...';

  @override
  String get historyTitle => 'ታሪክ';

  @override
  String get tabTimesheet => 'የጊዜ ሰሌዳ';

  @override
  String get tabWorksheet => 'የስራ ሉህ';

  @override
  String get noTimesheetDay => 'በዚህ ቀን የጊዜ ሰሌዳ አልተገኘም።';

  @override
  String get noWorksheetDay => 'በዚህ ቀን የስራ ሉህ አልተገኘም።';

  @override
  String get noWorksheetNeedAttendance =>
      'በዚህ ቀን መገኘት የለም። መጀመሪያ ይግቡ፣ ከዚያ የስራ ሉህ ማከል ይችላሉ።';

  @override
  String get worksheetAfterCheckout => 'መጀመሪያ ይግቡ፣ ከዚያ ለዚህ ቀን የስራ ሉህ ማከል ይችላሉ።';

  @override
  String get daysNeedingWorksheet => 'የስራ ሉህ የሚያስፈልጋቸው ቀናት';

  @override
  String get tapDayToAddWorksheet => 'የስራ ሉህ ለማከል ከታች ቀን ይንኩ።';

  @override
  String get existingWorksheets => 'የእርስዎ የስራ ሉሆች';

  @override
  String get tapDayToEditWorksheet => 'ለማርትዕ ከታች ቀን ይንኩ።';

  @override
  String get checkIn => 'ግባ';

  @override
  String get checkOut => 'ውጣ';

  @override
  String get closeShift => 'ሰዓት ዝጋ';

  @override
  String get checkingLocation => 'ቦታ በመፈተሽ ላይ...';

  @override
  String get authorizedLocation => 'የተፈቀደ ቦታ';

  @override
  String get outsideAuthorized => 'ከየተፈቀደ ቦታ ውጭ';

  @override
  String get locatingLocation => 'ቦታዎ በመፈለግ ላይ...';

  @override
  String get locationUnavailable => 'ቦታ አልተገኘም';

  @override
  String get locationTapToAllow => 'ቦታ ለመፍቀድ ይንኩ';

  @override
  String get locationPermissionHint =>
      'ለመግባት ቦታ ያስፈልጋል። እዚህ ይንኩ እና ብራውዘር ወይም መሣሪያ ሲጠይቅ ይፍቀዱ።';

  @override
  String get locationPermissionWebHint =>
      'መጠይቅ ካልመጣ ከሆነ፣ በብራውዘር ቅንብሮች ለዚህ ጣቢያ ቦታ ይፍቀዱ (🔒 → Site settings → Location)፣ ከዚያ እንደገና ይንኩ።';

  @override
  String get locationPermissionBlockedHint =>
      'ቦታ ታግዷል። ቅንብሮችን ለመክፈት እና ለመፍቀድ ይንኩ።';

  @override
  String get locationServicesOffHint =>
      'የቦታ አገልግሎት ጠፍቷል። ቅንብሮችን ለመክፈት እና ለማብራት ይንኩ።';

  @override
  String get companyPcLocation => 'የኩባንያ ኮምፖተር';

  @override
  String get locationNotRequired => 'በዚህ መሣሪያ ቦታ አያስፈልግም';

  @override
  String get readyToCheckIn => 'ለመግባት ዝግጁ';

  @override
  String get readyToCheckOut => 'ለመውጣት ዝግጁ';

  @override
  String get shiftInProgress => 'ሰዓት በሂደት ላይ';

  @override
  String get shiftComplete => 'ሰዓት ተጠናቀቀ';

  @override
  String get notCheckedIn => 'አልገባም';

  @override
  String get checkedIn => 'ገባ';

  @override
  String get checkedInLate => 'ገባ · ዘግይቷል';

  @override
  String get openShiftPending => 'የክፍት ሰዓት ውጣ ያስፈልጋል';

  @override
  String get attendanceCompleted => 'ተጠናቀቀ';

  @override
  String timeClockWorked(String duration) {
    return 'የሰራ $duration';
  }

  @override
  String timeClockScheduled(String duration) {
    return 'የሚመከር $duration';
  }

  @override
  String get done => 'ተጠናቀቀ';

  @override
  String openShiftFrom(String date) {
    return 'ከ $date ክፍት ሰዓት። ዛሬ ለመጀመር ከታች ውጣ ይጫኑ።';
  }

  @override
  String checkedInAt(String time) {
    return 'በ $time ገባ';
  }

  @override
  String checkedInOnAt(String date, String time) {
    return 'በ $date በ $time ገባ';
  }

  @override
  String get moveInsideZone => 'ለመግባት ወደ የተፈቀደ ዞን ይግቡ';

  @override
  String get checkInNeedsInternet => 'መግባት የበይነመረብ ግንኙነት ያስፈልጋል።';

  @override
  String get checkoutNeedsInternet => 'መውጣት የበይነመረብ ግንኙነት ያስፈልጋል።';

  @override
  String get checkoutCancelled => 'መውጣት ተሰርዘ።';

  @override
  String get checkInCancelled => 'መግባት ተሰርዘ። ለመቀጠል የዘግይታ ምክንያት ያስፈልጋል።';

  @override
  String outsideRadius(int meters) {
    return 'ከየተፈቀደ ቦታ ውጭ ነዎት ($meters ሜትር)። ይቅርቡ እና እንደገና ይሞክሩ።';
  }

  @override
  String metersAway(int meters) {
    return '$meters ሜትር ከቢሮ';
  }

  @override
  String metersAwayShort(int meters) {
    return '$meters ሜትር ውጭ';
  }

  @override
  String get checkInSuccessMorning => 'እንደምን አደር! መግባት ተሳካ። ምርታም ቀን ይኑርልዎ!';

  @override
  String get checkInSuccessAfternoon => 'እንደምን አደር! መግባት ተሳካ። መሻሻልዎን ይቀጥሉ!';

  @override
  String get checkInSuccessEvening =>
      'እንደምን አደር! መግባት ተሳካ። ስራዎን ስለ ጀመሩ እናመሰግናለን።';

  @override
  String checkInLate(int minutes, String dayPart) {
    return '$minutes ደቂቃ ዘግይታ ገብተዋል። ምክንያትዎን ስለጋሩ — መልካም $dayPart።';
  }

  @override
  String checkoutSuccess(String worked) {
    return 'በተሳካ ሁኔታ ወጡ — $worked ሰሩ።';
  }

  @override
  String previousShiftClosed(String worked) {
    return 'የቀድሞ ሰዓት ተዘጋ ($worked ተመዘገበ)። ዛሬ መግባት ይችላሉ።';
  }

  @override
  String get dayPartMorning => 'ጥዋት';

  @override
  String get dayPartAfternoon => 'ከሰዓት';

  @override
  String get dayPartEvening => 'ማታ';

  @override
  String get finishWorkday => 'ውጣ';

  @override
  String get closeOpenShift => 'ክፍት ሰዓት ዝጋ';

  @override
  String get checkoutDescribeToday => 'መውጣት ከመጀመርዎ ዛሬ ስራዎን ይግለጹ።';

  @override
  String get checkoutDescribeTodayOptional =>
      'ከፈለጉ ዛሬ ስራዎን ይግለጹ። ያለ የስራ ሉህ መውጣት ይችላሉ።';

  @override
  String checkoutCloseShiftHint(String date) {
    return 'ይህ ከ $date ሰዓት ይዘጋል። ከዚያ ዛሬ መግባት ይችላሉ።';
  }

  @override
  String get workSummary => 'የስራ ማጠቃለያ';

  @override
  String get workSummaryOptional => 'የስራ ማጠቃለያ (አማራጭ)';

  @override
  String get workSummaryHint => 'ለምሳሌ: ደንበኛ መመዝገብ እና የቡድን ስብሰባ...';

  @override
  String get workSummaryShiftHint => 'በዚያ ሰዓት የተከናወነ ስራ ይግለጹ...';

  @override
  String get worksheetOptionalHint =>
      'ባዶ ይተዉት ያለ የስራ ሉህ ለመውጣት። በኋላ ከታሪክ ማከል ይችላሉ።';

  @override
  String get skipAndCheckOut => 'ዝለል እና ውጣ';

  @override
  String get skipAndCloseShift => 'ዝለል እና ዝጋ';

  @override
  String get readyToSubmit => 'ለመላክ ዝግጁ';

  @override
  String minChars(int min, int current) {
    return 'ቢያንስ $min ቁምፊ · $current/$min';
  }

  @override
  String get addWorksheet => 'የስራ ሉህ ጨምር';

  @override
  String get editWorksheet => 'የስራ ሉህ አርትዕ';

  @override
  String get saveWorksheet => 'አስቀምጥ';

  @override
  String get worksheetSaved => 'የስራ ሉህ ተቀመጠ።';

  @override
  String get reviewed => 'ተገምግሟል';

  @override
  String get cancel => 'ሰርዝ';

  @override
  String lateCheckInTitle(int minutes) {
    return '$minutes ደቂቃ ዘግይተዋል';
  }

  @override
  String get lateCheckInSubtitle => 'ዛሬ በማንኛውም ጊዜ መግባት ይችላሉ። ለመቀጠል ምክንያት ይምረጡ።';

  @override
  String get continueCheckIn => 'መግባት ቀጥል';

  @override
  String get tellUsWhy => 'ምክንያት ይንገሩን';

  @override
  String get leaveTitle => 'ፍቃድ';

  @override
  String get profileTitle => 'መገለጫ';

  @override
  String get notificationsTitle => 'ማሳወቂያዎች';

  @override
  String get changePassword => 'የይለፍ ቃል ቀይር';

  @override
  String get currentPassword => 'የአሁን የይለፍ ቃል';

  @override
  String get newPassword => 'አዲስ የይለፍ ቃል';

  @override
  String get confirmPassword => 'የይለፍ ቃል አረጋግጥ';

  @override
  String get update => 'አዘምን';

  @override
  String get signOut => 'ውጣ';

  @override
  String get passwordChanged => 'የይለፍ ቃል በተሳካ ሁኔታ ተቀይረ።';

  @override
  String get passwordRules => 'የይለፍ ቃሎች መዛመድ አለባቸው እና ቢያንስ 6 ቁምፊ መሆን አለባቸው።';

  @override
  String get accountId => 'መለያ ID';

  @override
  String get role => 'ሚና';

  @override
  String get access => 'መዳረሻ';

  @override
  String permissionsCount(int count) {
    return '$count ፈቃዶች';
  }

  @override
  String get settingsLanguage => 'ቋንቋ';

  @override
  String get settingsTheme => 'ገጽታ';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageAmharic => 'አማርኛ';

  @override
  String get languageEnglishShort => 'Eng';

  @override
  String get languageAmharicShort => 'ኣማ';

  @override
  String get themeLight => 'ብርሃን';

  @override
  String get themeDark => 'ጨለማ';

  @override
  String get preferences => 'ቅንብሮች';

  @override
  String get onTime => 'በሰዓት';

  @override
  String get late => 'ዘግይቷል';

  @override
  String get missingCheckout => 'ውጣት አልተገኘም';

  @override
  String get submitted => 'ተላከ';

  @override
  String get checkInLabel => 'መግባት';

  @override
  String get checkOutLabel => 'መውጣት';

  @override
  String get worked => 'የሰራ';

  @override
  String get lateMinutes => 'ዘግይታ';

  @override
  String get earlyCheckout => 'ቀደም ተውጣ';

  @override
  String get overtime => 'ተጨማሪ ሰዓት';

  @override
  String get worksheetSubmitted => 'የስራ ሉህ ተላከ።';

  @override
  String workedDuration(String duration) {
    return '$duration ሰራ';
  }

  @override
  String get retry => 'እንደገና ይሞክሩ';

  @override
  String get offlineMessage => 'ከበይነመረብ ወጥተዋል። አንዳንድ ተግባራት ላልሰራ ይችላል።';

  @override
  String get approved => 'ጸድቋል';

  @override
  String get pending => 'በመጠባበቅ ላይ';

  @override
  String get rejected => 'ተቀባይነት አላገኘም';

  @override
  String get submitLeaveRequest => 'ጥያቄ ላክ';

  @override
  String get splashLoading => 'በመጫን ላይ...';

  @override
  String get splashSubtitle => 'ግባ፣ ሰዓትዎን ይከታተሉ፣ የጊዜ ሰሌድዎን ይመልከቱ';

  @override
  String get offlineBannerDetail =>
      'ከበይነመረብ ወጥተዋል — ታሪክ ይታያል፣ ግን የመገኘት ተግባራት ግንኙነት ያስፈልጋል።';

  @override
  String get errorTitle => 'አንድ ነገር ተሳስተ';

  @override
  String get connectionUnavailable => 'ግንኙነት አልተገኘም';

  @override
  String get connectionRetryHint =>
      'ግንኙነትዎን ይፈትሹ እና እንደገና ይሞክሩ። የተቀመጡ ውሂቦች አልተለወጡም።';

  @override
  String get tryAgain => 'እንደገና ይሞክሩ';

  @override
  String get leaveHistory => 'የፍቃድ ታሪክ';

  @override
  String get noLeaveRequests => 'ገና የፍቃድ ጥያቄ አልተገኘም።';

  @override
  String get requestLeave => 'ፍቃድ ጠይቅ';

  @override
  String get requestAttendanceCorrection => 'የመገኘት ማስተካከል ጠይቅ';

  @override
  String get leaveVsCorrectionHint =>
      'ከስራ ሲወጡ ፍቃድ ይጠቀሙ። በስራ ላይ ሲሆኑ ግን መግቢያ/መውጫ ካልተመዘገበ ማስተካከል ይጠቀሙ። ማስተካከል የፍቃድ ቀን አይቀንስም።';

  @override
  String get attendanceCorrectionHistory => 'የመገኘት ማስተካከሎች';

  @override
  String get noAttendanceCorrections => 'ገና የማስተካከል ጥያቄ የለም።';

  @override
  String get attendanceCorrectionSubmitted => 'የማስተካከል ጥያቄ ተላከ።';

  @override
  String get attendanceCorrectionTitle => 'የመገኘት ማስተካከል';

  @override
  String get attendanceCorrectionHint =>
      'በስራ ላይ ከሆኑ ቀኖችን አስተዳዳሪ እንዲያስተካክል ይጠይቁ። በፍቃድ ላይ ከሆኑ ቀኖች ላይ አይጠቀሙ።';

  @override
  String get attendanceCorrectionNoteLabel => 'ማስታወሻ (አማራጭ)';

  @override
  String get attendanceCorrectionNoteHint => 'ምሳ. መግቢያ ላይ ስህተት';

  @override
  String get attendanceCorrectionDatesLabel => 'ቀኖች';

  @override
  String get attendanceCorrectionAddDate => 'ቀን ጨምር';

  @override
  String get attendanceCorrectionPickDate => 'ያለፈውን ቢያንስ አንድ ቀን ይምረጡ።';

  @override
  String get attendanceCorrectionSubmit => 'ማስተካከል ላክ';

  @override
  String get attendanceCorrectionDateBlocked =>
      'ቀኑ ቀድሞ በመጠባበቅ/ተፈቅዷል ወይም በፍቃድ ላይ ነበር።';

  @override
  String get attendanceCorrectionStatusPending => 'በመጠባበቅ';

  @override
  String get attendanceCorrectionStatusApproved => 'ተፈቅዷል';

  @override
  String get attendanceCorrectionStatusRejected => 'ተቀባይነት አላገኘም';

  @override
  String get leaveRequestSubmitted => 'የፍቃድ ጥያቄ ተላከ።';

  @override
  String get annualLeaveTitle => 'ዓመታዊ ፍቃድ';

  @override
  String get annualLeaveDaysAvailable => 'ቀናት ይቀራሉ';

  @override
  String annualLeaveThisYear(String days) {
    return 'የዚህ ዓመት $days';
  }

  @override
  String annualLeaveCarried(String days) {
    return 'ተሸጋገረ $days';
  }

  @override
  String annualLeaveUsed(String days) {
    return 'ተጠቅመዋል $days';
  }

  @override
  String annualLeavePendingDays(String days) {
    return 'በመጠባበቅ $days';
  }

  @override
  String annualLeaveServiceYears(String years) {
    return '$years ዓመት አገልግሎት';
  }

  @override
  String annualLeaveNextGrant(String days, String date) {
    return 'ቀጣይ $days ቀን በ $date';
  }

  @override
  String annualLeaveProRata(String days, String months) {
    return 'በመጠን: $days ከ 16 ቀን ($months ወር አገልግሎት)';
  }

  @override
  String annualLeaveExpires(String days, String date) {
    return '$days ቀን በ $date ያልቃሉ';
  }

  @override
  String get annualLeaveBreakdown => 'የፍቃድ ዓመታት';

  @override
  String annualLeaveAvailableHint(String days) {
    return '$days የዓመታዊ ፍቃድ ቀናት ይቀራሉ። የቆዩ የተሸጋገሩ ቀናት መጀመሪያ ይቀነሳሉ።';
  }

  @override
  String get leaveTypeLabel => 'የፍቃድ አይነት';

  @override
  String get leaveStartDate => 'መጀመሪያ ቀን';

  @override
  String get leaveEndDate => 'መጨረሻ ቀን';

  @override
  String get leaveReason => 'ምክንያት';

  @override
  String get leaveReasonHint => 'የፍቃድ ጥያቄዎን በአጭሩ ያብራሩ';

  @override
  String get leavePastDatesHint =>
      'ያለፉ ቀናት ለጎደሉ የመገኘት ቀናት ይፈቀዳሉ። ቀናት ከስራ መርሃ ግብር ይቆጠራሉ (ግማሽ ቀን = 0.5)።';

  @override
  String get cancelRequest => 'ጥያቄ ሰርዝ';

  @override
  String adminNote(String note) {
    return 'አስተዳዳሪ: $note';
  }

  @override
  String get notificationsTooltip => 'ማሳወቂያዎች';

  @override
  String get accountCreatedByAdmin => 'መለያዎ በአስተዳዳሪዎ ተፈጥረ።';

  @override
  String get refresh => 'አድስ';

  @override
  String get enterEmailOrCode => 'ኢሜይል ወይም የሰራተኛ ኮድ ያስገቡ';

  @override
  String get passwordMin8 => 'የይለፍ ቃል ቢያንስ 6 ቁምፊ መሆን አለበት';

  @override
  String get thatDay => 'በዚያ ቀን';

  @override
  String get reasonTraffic => 'ትራፊክ';

  @override
  String get reasonTransportation => 'ትራንስፖርት';

  @override
  String get reasonHealth => 'ጤና';

  @override
  String get reasonFamilyEmergency => 'የቤተሰብ አደጋ';

  @override
  String get reasonWeather => 'አየር';

  @override
  String get reasonOther => 'ሌላ';

  @override
  String timeRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String daysCount(String start, String end, String days) {
    return '$start – $end • $days ቀን(ዎች)';
  }

  @override
  String lateMinutesValue(int minutes) {
    return '$minutes ደቂቃ';
  }

  @override
  String earlyCheckoutMinutes(int minutes) {
    return '$minutes ደቂቃ';
  }

  @override
  String overtimeMinutes(int minutes) {
    return '$minutes ደቂቃ';
  }

  @override
  String get dash => '—';

  @override
  String get readAll => 'ሁሉን አንብብ';

  @override
  String get noNotificationsYet => 'ገና ማሳወቂያ አልተገኘም።';

  @override
  String get notificationTapToOpen => 'ለመክፈት ይጫኑ';

  @override
  String get notificationNoLinkedScreen =>
      'ለዚህ ማሳወቂያ ተያያዥ ገጽ የለም። ከሜኑ Leave ወይም History ይሞክሩ።';

  @override
  String get photoCaptureTitleCheckIn => 'መግባት ያረጋግጡ';

  @override
  String get photoCaptureTitleCheckOut => 'መውጣት ያረጋግጡ';

  @override
  String get photoCaptureHint => 'ፊትዎን በክብ ውስጥ ያስቀምጡ';

  @override
  String get photoCaptureButton => 'ፎቶ ይውሰዱ';

  @override
  String get photoRetake => 'እንደገና';

  @override
  String get photoUse => 'ፎቶ ተጠቀም';

  @override
  String get photoUploading => 'ፎቶ በመላክ ላይ...';

  @override
  String get photoCaptureFailed => 'ፎቶ ማንሳት አልተሳካም። እንደገና ይሞክሩ።';

  @override
  String get photoCameraPermissionRequired =>
      'የማረጋገጫ ፎቶ ለመውሰድ ካሜራ ፍቃድ ያስፈልጋል። ካሜራ ፍቃድ ይፍቀዱና እንደገና ይሞክሩ።';

  @override
  String get photoCameraPermissionWeb =>
      'ካሜራ ፍቃድ ያስፈልጋል። በብራውዘር ቅንብሮች ለዚህ ጣቢያ ካሜራ ይፍቀዱና እንደገና ይሞክሩ።';

  @override
  String get photoOpenSettings => 'ቅንብሮች ክፈት';

  @override
  String get evaluationsTitle => 'ግምገማዎች';

  @override
  String get noEvaluationsYet => 'ገና ግምገማ የለም።';

  @override
  String evaluationDue(String date) {
    return 'የመጨረሻ ቀን $date';
  }

  @override
  String evaluationSelfAverage(String value) {
    return 'የራስ አማካይ: $value';
  }

  @override
  String evaluationDueCard(String name) {
    return 'የ$name ግምገማዎን ይሙሉ';
  }

  @override
  String get evaluationStatusOpen => 'እርምጃ ያስፈልጋል';

  @override
  String get evaluationStatusWaiting => 'ከገምጋሚ ጋር';

  @override
  String get evaluationStatusScored => 'ተገምግሟል';

  @override
  String get evaluationStatusFinal => 'የተጠናቀቀ';

  @override
  String get evaluationStatusClosed => 'ተዘግቷል';

  @override
  String get evaluationCycleClosedBanner =>
      'ይህ የግምገማ ዑደት ተዘግቷል። ውጤቶችዎ ከዚህ በታች ይታያሉ።';

  @override
  String evaluationEvaluatorTotal(String value) {
    return 'የግምገማ አጠቃላይ: $value';
  }

  @override
  String get evaluationStepInfo => 'የሰራተኛ መረጃ';

  @override
  String get evaluationStepMetrics => 'መለኪያዎች';

  @override
  String get evaluationStepRoles => 'ሚናዎች እና ኃላፊነቶች';

  @override
  String get evaluationStepSkills => 'የተሻሻሉ ክህሎቶች';

  @override
  String get evaluationStepGoals => 'የልማት ግቦች';

  @override
  String get evaluationStepReview => 'ይገምግሙ እና ይላኩ';

  @override
  String get evaluationEmployee => 'ስም';

  @override
  String get evaluationPosition => 'የስራ መደብ';

  @override
  String get evaluationSupervisor => 'ቀጥተኛ ኃላፊ';

  @override
  String get evaluationPeriod => 'ጊዜ';

  @override
  String get evaluationNumber => 'ቁጥር';

  @override
  String evaluationPrevious(String value) {
    return 'ቀዳሚ: $value';
  }

  @override
  String get evaluationPickDate => 'የዒላማ ቀን ይምረጡ';

  @override
  String get evaluationCriteria => 'የግምገማ መስፈርት';

  @override
  String get evaluationReviewHint => 'ውጤቶችዎን ያረጋግጡና ይላኩ። ከተላከ በኋላ መቀየር አይችሉም።';

  @override
  String get evaluationFocus => 'የትኩረት ብቃት';

  @override
  String get evaluationActionPlan => 'የእርምጃ እቅድ';

  @override
  String evaluationEvaluatorScore(String value) {
    return 'ገምጋሚ: $value';
  }

  @override
  String get evaluationSubmit => 'የራስ ግምገማ ላክ';

  @override
  String get evaluationSubmitConfirm =>
      'ውጤቶችዎን ለገምጋሚ ይላኩ? ከዚያ በኋላ ማስተካከል አይችሉም።';

  @override
  String get evaluationSubmitted => 'የራስ ግምገማ ተልኳል።';

  @override
  String get evaluationIncomplete =>
      'እያንዳንዱን ክፍል ከ 1 እስከ 5 ይስጡ። መገኘት በስርዓቱ ይሰላል።';

  @override
  String get back => 'ተመለስ';

  @override
  String get next => 'ቀጣይ';

  @override
  String get meetingsTitle => 'ስብሰባዎች';

  @override
  String get bookMeeting => 'ክፍል ያስይዙ';

  @override
  String get noMeetingsYet => 'እስካሁን ቦታ አልተያዘም።';

  @override
  String get meetingBooked => 'ክፍሉ ተይዟል።';

  @override
  String get meetingCancelled => 'ቦታ ማስያዙ ተሰርዟል።';

  @override
  String get meetingRoom => 'ክፍል';

  @override
  String get meetingTitle => 'ርዕስ';

  @override
  String get meetingNotes => 'ማስታወሻ (አማራጭ)';

  @override
  String get meetingStart => 'መጀመሪያ';

  @override
  String get meetingEnd => 'መጨረሻ';

  @override
  String get meetingBusy => 'ተይዟል';

  @override
  String get pickRoom => 'ክፍል ይምረጡ';

  @override
  String get confirmCancelMeeting => 'ይህን ቦታ ማስያዝ ይሰረዝ?';

  @override
  String get newChat => 'አዲስ ውይይት';

  @override
  String get noChatsYet => 'እስካሁን ውይይት የለም።';

  @override
  String get noChatsHint => 'ከስራ ባልደረባ ጋር የግል ውይይት ይጀምሩ።';

  @override
  String get searchColleagues => 'ባልደረቦችን ፈልግ';

  @override
  String get noColleaguesFound => 'ባልደረባ አልተገኘም።';

  @override
  String get noMessagesYet => 'መልእክት የለም';

  @override
  String get sayHello => 'ውይይቱን ለመጀመር ሰላም በሉ።';

  @override
  String get messageHint => 'መልእክት';

  @override
  String get contextPickerTitle => 'በምን መንገድ ይግቡ?';

  @override
  String get contextPickerSubtitle =>
      'መለያዎ ተጨማሪ ሚናዎች አሉት። ይህን መተግበሪያ ለመጠቀም Employee ይምረጡ።';

  @override
  String get contextSuggested => 'የተመከረ';

  @override
  String get switchContext => 'ሚና ቀይር';

  @override
  String get switchToEmployee => 'እንደ ሰራተኛ';

  @override
  String nonEmployeeContextBanner(String role) {
    return 'እንደ $role ገብተዋል። የመግቢያ ባህሪዎች የEmployee ሚና ይፈልጋሉ።';
  }

  @override
  String get backToSignIn => 'ወደ መግቢያ ተመለስ';

  @override
  String get updateRequiredTitle => 'ማዘመን ያስፈልጋል';

  @override
  String get updateRequiredBody =>
      'ይህ ስሪት አሁን አይደገፍም። መቀጠል ከፈለጉ መተግበሪያውን ያዘምኑ።';

  @override
  String get updateAvailableTitle => 'አዲስ ስሪት አለ';

  @override
  String get updateAvailableBody =>
      'አዲስ ስሪት ዝግጁ ነው። አሁን ማዘመን ወይም በኋላ ከምናሌው ማዘመን ይችላሉ።';

  @override
  String get updateNow => 'አሁን አዘምን';

  @override
  String get updateLater => 'በኋላ';

  @override
  String get updateOpenFailed => 'የማውረጃ ገጹን መክፈት አልተቻለም።';

  @override
  String currentVersion(String version) {
    return 'የአሁኑ ስሪት: $version';
  }

  @override
  String latestVersion(String version) {
    return 'አዲሱ ስሪት: $version';
  }

  @override
  String appVersionLabel(String version) {
    return 'Work-Force v$version';
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Work-Force'**
  String get appTitle;

  /// No description provided for @greetingHi.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String greetingHi(String name);

  /// No description provided for @navTimeClock.
  ///
  /// In en, this message translates to:
  /// **'Time Clock'**
  String get navTimeClock;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get navLeave;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navMeetings.
  ///
  /// In en, this message translates to:
  /// **'Meetings'**
  String get navMeetings;

  /// No description provided for @navPerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get navPerformance;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @drawerSectionWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get drawerSectionWork;

  /// No description provided for @drawerSectionWorkplace.
  ///
  /// In en, this message translates to:
  /// **'Workplace'**
  String get drawerSectionWorkplace;

  /// No description provided for @drawerSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get drawerSectionAccount;

  /// No description provided for @openMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get openMenu;

  /// No description provided for @employeeWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Employee workspace'**
  String get employeeWorkspace;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Work-Force'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Employee sign in · use your work email or employee code.'**
  String get loginSubtitle;

  /// No description provided for @emailOrCode.
  ///
  /// In en, this message translates to:
  /// **'Email or employee code'**
  String get emailOrCode;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @tabTimesheet.
  ///
  /// In en, this message translates to:
  /// **'Timesheet'**
  String get tabTimesheet;

  /// No description provided for @tabWorksheet.
  ///
  /// In en, this message translates to:
  /// **'Worksheet'**
  String get tabWorksheet;

  /// No description provided for @noTimesheetDay.
  ///
  /// In en, this message translates to:
  /// **'No timesheet for this day.'**
  String get noTimesheetDay;

  /// No description provided for @noWorksheetDay.
  ///
  /// In en, this message translates to:
  /// **'No worksheet for this day.'**
  String get noWorksheetDay;

  /// No description provided for @noWorksheetNeedAttendance.
  ///
  /// In en, this message translates to:
  /// **'No attendance for this day. Check in first, then you can add a worksheet.'**
  String get noWorksheetNeedAttendance;

  /// No description provided for @worksheetAfterCheckout.
  ///
  /// In en, this message translates to:
  /// **'Check in first, then you can add a worksheet for this day.'**
  String get worksheetAfterCheckout;

  /// No description provided for @daysNeedingWorksheet.
  ///
  /// In en, this message translates to:
  /// **'Days needing a worksheet'**
  String get daysNeedingWorksheet;

  /// No description provided for @tapDayToAddWorksheet.
  ///
  /// In en, this message translates to:
  /// **'Tap a day below to open it and add a worksheet.'**
  String get tapDayToAddWorksheet;

  /// No description provided for @existingWorksheets.
  ///
  /// In en, this message translates to:
  /// **'Your worksheets'**
  String get existingWorksheets;

  /// No description provided for @tapDayToEditWorksheet.
  ///
  /// In en, this message translates to:
  /// **'Tap a day below to open and edit that worksheet.'**
  String get tapDayToEditWorksheet;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get checkIn;

  /// No description provided for @checkOut.
  ///
  /// In en, this message translates to:
  /// **'Check out'**
  String get checkOut;

  /// No description provided for @closeShift.
  ///
  /// In en, this message translates to:
  /// **'Close shift'**
  String get closeShift;

  /// No description provided for @checkingLocation.
  ///
  /// In en, this message translates to:
  /// **'Checking location...'**
  String get checkingLocation;

  /// No description provided for @authorizedLocation.
  ///
  /// In en, this message translates to:
  /// **'Authorized location'**
  String get authorizedLocation;

  /// No description provided for @outsideAuthorized.
  ///
  /// In en, this message translates to:
  /// **'Outside authorized area'**
  String get outsideAuthorized;

  /// No description provided for @locatingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting your location...'**
  String get locatingLocation;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get locationUnavailable;

  /// No description provided for @locationTapToAllow.
  ///
  /// In en, this message translates to:
  /// **'Tap to allow location'**
  String get locationTapToAllow;

  /// No description provided for @locationPermissionHint.
  ///
  /// In en, this message translates to:
  /// **'Location is required for check-in. Tap here and allow when your browser or device asks.'**
  String get locationPermissionHint;

  /// No description provided for @locationPermissionWebHint.
  ///
  /// In en, this message translates to:
  /// **'If no prompt appears, allow location for this site in browser settings (lock icon → Site settings → Location), then tap here again.'**
  String get locationPermissionWebHint;

  /// No description provided for @locationPermissionBlockedHint.
  ///
  /// In en, this message translates to:
  /// **'Location is blocked. Tap to open settings and allow access.'**
  String get locationPermissionBlockedHint;

  /// No description provided for @locationServicesOffHint.
  ///
  /// In en, this message translates to:
  /// **'Location services are off. Tap to open settings and turn them on.'**
  String get locationServicesOffHint;

  /// No description provided for @companyPcLocation.
  ///
  /// In en, this message translates to:
  /// **'Company PC'**
  String get companyPcLocation;

  /// No description provided for @locationNotRequired.
  ///
  /// In en, this message translates to:
  /// **'Location is not required on this device'**
  String get locationNotRequired;

  /// No description provided for @readyToCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Ready to check in'**
  String get readyToCheckIn;

  /// No description provided for @readyToCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Ready to check out'**
  String get readyToCheckOut;

  /// No description provided for @shiftInProgress.
  ///
  /// In en, this message translates to:
  /// **'Shift in progress'**
  String get shiftInProgress;

  /// No description provided for @shiftComplete.
  ///
  /// In en, this message translates to:
  /// **'Shift complete'**
  String get shiftComplete;

  /// No description provided for @notCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Not checked in'**
  String get notCheckedIn;

  /// No description provided for @checkedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get checkedIn;

  /// No description provided for @checkedInLate.
  ///
  /// In en, this message translates to:
  /// **'Checked in · Late'**
  String get checkedInLate;

  /// No description provided for @openShiftPending.
  ///
  /// In en, this message translates to:
  /// **'Open shift pending checkout'**
  String get openShiftPending;

  /// No description provided for @attendanceCompleted.
  ///
  /// In en, this message translates to:
  /// **'Attendance completed'**
  String get attendanceCompleted;

  /// No description provided for @timeClockWorked.
  ///
  /// In en, this message translates to:
  /// **'Worked {duration}'**
  String timeClockWorked(String duration);

  /// No description provided for @timeClockScheduled.
  ///
  /// In en, this message translates to:
  /// **'Recommended {duration}'**
  String timeClockScheduled(String duration);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @openShiftFrom.
  ///
  /// In en, this message translates to:
  /// **'Open shift from {date}. Check out below to start today.'**
  String openShiftFrom(String date);

  /// No description provided for @checkedInAt.
  ///
  /// In en, this message translates to:
  /// **'Checked in at {time}'**
  String checkedInAt(String time);

  /// No description provided for @checkedInOnAt.
  ///
  /// In en, this message translates to:
  /// **'Checked in {date} at {time}'**
  String checkedInOnAt(String date, String time);

  /// No description provided for @moveInsideZone.
  ///
  /// In en, this message translates to:
  /// **'Move inside the authorized zone to check in'**
  String get moveInsideZone;

  /// No description provided for @checkInNeedsInternet.
  ///
  /// In en, this message translates to:
  /// **'Check-in needs an internet connection.'**
  String get checkInNeedsInternet;

  /// No description provided for @checkoutNeedsInternet.
  ///
  /// In en, this message translates to:
  /// **'Checkout needs an internet connection.'**
  String get checkoutNeedsInternet;

  /// No description provided for @checkoutCancelled.
  ///
  /// In en, this message translates to:
  /// **'Checkout cancelled.'**
  String get checkoutCancelled;

  /// No description provided for @checkInCancelled.
  ///
  /// In en, this message translates to:
  /// **'Check-in cancelled. Add a late reason to continue.'**
  String get checkInCancelled;

  /// No description provided for @outsideRadius.
  ///
  /// In en, this message translates to:
  /// **'You are outside the allowed office radius ({meters} m away). Move closer and try again.'**
  String outsideRadius(int meters);

  /// No description provided for @metersAway.
  ///
  /// In en, this message translates to:
  /// **'{meters} m from office'**
  String metersAway(int meters);

  /// No description provided for @metersAwayShort.
  ///
  /// In en, this message translates to:
  /// **'{meters} m away'**
  String metersAwayShort(int meters);

  /// No description provided for @checkInSuccessMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning! Check-in successful. Have a productive day.'**
  String get checkInSuccessMorning;

  /// No description provided for @checkInSuccessAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon! Check-in successful. Keep up the good work.'**
  String get checkInSuccessAfternoon;

  /// No description provided for @checkInSuccessEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening! Check-in successful. Thanks for starting your shift.'**
  String get checkInSuccessEvening;

  /// No description provided for @checkInLate.
  ///
  /// In en, this message translates to:
  /// **'Checked in {minutes} min late. Thanks for sharing your reason — have a good {dayPart}.'**
  String checkInLate(int minutes, String dayPart);

  /// No description provided for @checkoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Checked out successfully — you worked {worked}.'**
  String checkoutSuccess(String worked);

  /// No description provided for @previousShiftClosed.
  ///
  /// In en, this message translates to:
  /// **'Previous shift closed ({worked} recorded). You can check in for today now.'**
  String previousShiftClosed(String worked);

  /// No description provided for @dayPartMorning.
  ///
  /// In en, this message translates to:
  /// **'morning'**
  String get dayPartMorning;

  /// No description provided for @dayPartAfternoon.
  ///
  /// In en, this message translates to:
  /// **'afternoon'**
  String get dayPartAfternoon;

  /// No description provided for @dayPartEvening.
  ///
  /// In en, this message translates to:
  /// **'evening'**
  String get dayPartEvening;

  /// No description provided for @finishWorkday.
  ///
  /// In en, this message translates to:
  /// **'Check out'**
  String get finishWorkday;

  /// No description provided for @closeOpenShift.
  ///
  /// In en, this message translates to:
  /// **'Close open shift'**
  String get closeOpenShift;

  /// No description provided for @checkoutDescribeToday.
  ///
  /// In en, this message translates to:
  /// **'Describe what you worked on today before checking out.'**
  String get checkoutDescribeToday;

  /// No description provided for @checkoutDescribeTodayOptional.
  ///
  /// In en, this message translates to:
  /// **'Optionally describe what you worked on today. You can skip and check out without a worksheet.'**
  String get checkoutDescribeTodayOptional;

  /// No description provided for @checkoutCloseShiftHint.
  ///
  /// In en, this message translates to:
  /// **'This closes your shift from {date}. You can check in for today afterward.'**
  String checkoutCloseShiftHint(String date);

  /// No description provided for @workSummary.
  ///
  /// In en, this message translates to:
  /// **'Work summary'**
  String get workSummary;

  /// No description provided for @workSummaryOptional.
  ///
  /// In en, this message translates to:
  /// **'Work summary (optional)'**
  String get workSummaryOptional;

  /// No description provided for @workSummaryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Completed client onboarding and team standup...'**
  String get workSummaryHint;

  /// No description provided for @workSummaryShiftHint.
  ///
  /// In en, this message translates to:
  /// **'Summarize tasks completed during that shift...'**
  String get workSummaryShiftHint;

  /// No description provided for @worksheetOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to check out without a worksheet. You can add it later from History.'**
  String get worksheetOptionalHint;

  /// No description provided for @skipAndCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Skip & check out'**
  String get skipAndCheckOut;

  /// No description provided for @skipAndCloseShift.
  ///
  /// In en, this message translates to:
  /// **'Skip & close'**
  String get skipAndCloseShift;

  /// No description provided for @readyToSubmit.
  ///
  /// In en, this message translates to:
  /// **'Ready to submit'**
  String get readyToSubmit;

  /// No description provided for @minChars.
  ///
  /// In en, this message translates to:
  /// **'Minimum {min} characters · {current}/{min}'**
  String minChars(int min, int current);

  /// No description provided for @addWorksheet.
  ///
  /// In en, this message translates to:
  /// **'Add worksheet'**
  String get addWorksheet;

  /// No description provided for @editWorksheet.
  ///
  /// In en, this message translates to:
  /// **'Edit worksheet'**
  String get editWorksheet;

  /// No description provided for @saveWorksheet.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveWorksheet;

  /// No description provided for @worksheetSaved.
  ///
  /// In en, this message translates to:
  /// **'Worksheet saved.'**
  String get worksheetSaved;

  /// No description provided for @reviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get reviewed;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @lateCheckInTitle.
  ///
  /// In en, this message translates to:
  /// **'You are {minutes} minute(s) late'**
  String lateCheckInTitle(int minutes);

  /// No description provided for @lateCheckInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can still check in any time today. Select a reason to continue.'**
  String get lateCheckInSubtitle;

  /// No description provided for @continueCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Continue check-in'**
  String get continueCheckIn;

  /// No description provided for @tellUsWhy.
  ///
  /// In en, this message translates to:
  /// **'Tell us why'**
  String get tellUsWhy;

  /// No description provided for @leaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChanged;

  /// No description provided for @passwordRules.
  ///
  /// In en, this message translates to:
  /// **'Passwords must match and be at least 6 characters.'**
  String get passwordRules;

  /// No description provided for @accountId.
  ///
  /// In en, this message translates to:
  /// **'Account ID'**
  String get accountId;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @access.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get access;

  /// No description provided for @permissionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} permissions'**
  String permissionsCount(int count);

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageAmharic.
  ///
  /// In en, this message translates to:
  /// **'አማርኛ'**
  String get languageAmharic;

  /// No description provided for @languageEnglishShort.
  ///
  /// In en, this message translates to:
  /// **'Eng'**
  String get languageEnglishShort;

  /// No description provided for @languageAmharicShort.
  ///
  /// In en, this message translates to:
  /// **'ኣማ'**
  String get languageAmharicShort;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @onTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get onTime;

  /// No description provided for @late.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get late;

  /// No description provided for @missingCheckout.
  ///
  /// In en, this message translates to:
  /// **'Missing checkout'**
  String get missingCheckout;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @checkInLabel.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get checkInLabel;

  /// No description provided for @checkOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Check-out'**
  String get checkOutLabel;

  /// No description provided for @worked.
  ///
  /// In en, this message translates to:
  /// **'Worked'**
  String get worked;

  /// No description provided for @lateMinutes.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get lateMinutes;

  /// No description provided for @earlyCheckout.
  ///
  /// In en, this message translates to:
  /// **'Early checkout'**
  String get earlyCheckout;

  /// No description provided for @overtime.
  ///
  /// In en, this message translates to:
  /// **'Overtime'**
  String get overtime;

  /// No description provided for @worksheetSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Worksheet submitted.'**
  String get worksheetSubmitted;

  /// No description provided for @workedDuration.
  ///
  /// In en, this message translates to:
  /// **'Worked {duration}'**
  String workedDuration(String duration);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @offlineMessage.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Some actions may not work.'**
  String get offlineMessage;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @submitLeaveRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit request'**
  String get submitLeaveRequest;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get splashLoading;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clock in, track your hours, review your timesheet'**
  String get splashSubtitle;

  /// No description provided for @offlineBannerDetail.
  ///
  /// In en, this message translates to:
  /// **'Offline — history remains visible, but attendance actions need a connection.'**
  String get offlineBannerDetail;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @connectionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Connection unavailable'**
  String get connectionUnavailable;

  /// No description provided for @connectionRetryHint.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again. Your saved server data is not changed.'**
  String get connectionRetryHint;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @leaveHistory.
  ///
  /// In en, this message translates to:
  /// **'Leave history'**
  String get leaveHistory;

  /// No description provided for @noLeaveRequests.
  ///
  /// In en, this message translates to:
  /// **'No leave requests yet.'**
  String get noLeaveRequests;

  /// No description provided for @requestLeave.
  ///
  /// In en, this message translates to:
  /// **'Request leave'**
  String get requestLeave;

  /// No description provided for @requestAttendanceCorrection.
  ///
  /// In en, this message translates to:
  /// **'Request attendance correction'**
  String get requestAttendanceCorrection;

  /// No description provided for @leaveVsCorrectionHint.
  ///
  /// In en, this message translates to:
  /// **'Use leave when you were absent. Use attendance correction when you worked but check-in or check-out is missing or wrong. Corrections do not use your leave balance.'**
  String get leaveVsCorrectionHint;

  /// No description provided for @attendanceCorrectionHistory.
  ///
  /// In en, this message translates to:
  /// **'Attendance corrections'**
  String get attendanceCorrectionHistory;

  /// No description provided for @noAttendanceCorrections.
  ///
  /// In en, this message translates to:
  /// **'No correction requests yet.'**
  String get noAttendanceCorrections;

  /// No description provided for @attendanceCorrectionSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Correction request submitted.'**
  String get attendanceCorrectionSubmitted;

  /// No description provided for @attendanceCorrectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance correction'**
  String get attendanceCorrectionTitle;

  /// No description provided for @attendanceCorrectionHint.
  ///
  /// In en, this message translates to:
  /// **'Ask your admin to mark selected days as worked (full scheduled shift). Only use this if you were at work—not for days you were on leave.'**
  String get attendanceCorrectionHint;

  /// No description provided for @attendanceCorrectionNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get attendanceCorrectionNoteLabel;

  /// No description provided for @attendanceCorrectionNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Forgot to check in at the office'**
  String get attendanceCorrectionNoteHint;

  /// No description provided for @attendanceCorrectionDatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get attendanceCorrectionDatesLabel;

  /// No description provided for @attendanceCorrectionAddDate.
  ///
  /// In en, this message translates to:
  /// **'Add date'**
  String get attendanceCorrectionAddDate;

  /// No description provided for @attendanceCorrectionPickDate.
  ///
  /// In en, this message translates to:
  /// **'Add at least one past working day.'**
  String get attendanceCorrectionPickDate;

  /// No description provided for @attendanceCorrectionSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit correction'**
  String get attendanceCorrectionSubmit;

  /// No description provided for @attendanceCorrectionDateBlocked.
  ///
  /// In en, this message translates to:
  /// **'That date already has a pending or approved correction, or you were on leave.'**
  String get attendanceCorrectionDateBlocked;

  /// No description provided for @attendanceCorrectionStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get attendanceCorrectionStatusPending;

  /// No description provided for @attendanceCorrectionStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get attendanceCorrectionStatusApproved;

  /// No description provided for @attendanceCorrectionStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get attendanceCorrectionStatusRejected;

  /// No description provided for @leaveRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Leave request submitted.'**
  String get leaveRequestSubmitted;

  /// No description provided for @annualLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Annual leave'**
  String get annualLeaveTitle;

  /// No description provided for @annualLeaveDaysAvailable.
  ///
  /// In en, this message translates to:
  /// **'days available'**
  String get annualLeaveDaysAvailable;

  /// No description provided for @annualLeaveThisYear.
  ///
  /// In en, this message translates to:
  /// **'This year {days}'**
  String annualLeaveThisYear(String days);

  /// No description provided for @annualLeaveCarried.
  ///
  /// In en, this message translates to:
  /// **'Carried {days}'**
  String annualLeaveCarried(String days);

  /// No description provided for @annualLeaveUsed.
  ///
  /// In en, this message translates to:
  /// **'Used {days}'**
  String annualLeaveUsed(String days);

  /// No description provided for @annualLeavePendingDays.
  ///
  /// In en, this message translates to:
  /// **'Pending {days}'**
  String annualLeavePendingDays(String days);

  /// No description provided for @annualLeaveServiceYears.
  ///
  /// In en, this message translates to:
  /// **'{years} years of service'**
  String annualLeaveServiceYears(String years);

  /// No description provided for @annualLeaveNextGrant.
  ///
  /// In en, this message translates to:
  /// **'Next grant {days} days on {date}'**
  String annualLeaveNextGrant(String days, String date);

  /// No description provided for @annualLeaveProRata.
  ///
  /// In en, this message translates to:
  /// **'Pro-rata: {days} of 16 days ({months} months of service)'**
  String annualLeaveProRata(String days, String months);

  /// No description provided for @annualLeaveExpires.
  ///
  /// In en, this message translates to:
  /// **'{days} days expire on {date}'**
  String annualLeaveExpires(String days, String date);

  /// No description provided for @annualLeaveBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Leave years'**
  String get annualLeaveBreakdown;

  /// No description provided for @annualLeaveAvailableHint.
  ///
  /// In en, this message translates to:
  /// **'{days} annual leave days remaining. Oldest carried days are used first.'**
  String annualLeaveAvailableHint(String days);

  /// No description provided for @leaveTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Leave type'**
  String get leaveTypeLabel;

  /// No description provided for @leaveStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get leaveStartDate;

  /// No description provided for @leaveEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get leaveEndDate;

  /// No description provided for @leaveReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get leaveReason;

  /// No description provided for @leaveReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Briefly explain your leave request'**
  String get leaveReasonHint;

  /// No description provided for @leavePastDatesHint.
  ///
  /// In en, this message translates to:
  /// **'Past dates are allowed for missing attendance days. Days are counted from your work schedule (half days count as 0.5).'**
  String get leavePastDatesHint;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get cancelRequest;

  /// No description provided for @adminNote.
  ///
  /// In en, this message translates to:
  /// **'Admin: {note}'**
  String adminNote(String note);

  /// No description provided for @notificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTooltip;

  /// No description provided for @accountCreatedByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Your account is created by your administrator.'**
  String get accountCreatedByAdmin;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @enterEmailOrCode.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or employee code'**
  String get enterEmailOrCode;

  /// No description provided for @passwordMin8.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMin8;

  /// No description provided for @thatDay.
  ///
  /// In en, this message translates to:
  /// **'that day'**
  String get thatDay;

  /// No description provided for @reasonTraffic.
  ///
  /// In en, this message translates to:
  /// **'Traffic'**
  String get reasonTraffic;

  /// No description provided for @reasonTransportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get reasonTransportation;

  /// No description provided for @reasonHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get reasonHealth;

  /// No description provided for @reasonFamilyEmergency.
  ///
  /// In en, this message translates to:
  /// **'Family emergency'**
  String get reasonFamilyEmergency;

  /// No description provided for @reasonWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get reasonWeather;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @timeRange.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String timeRange(String start, String end);

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end} • {days} day(s)'**
  String daysCount(String start, String end, String days);

  /// No description provided for @lateMinutesValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String lateMinutesValue(int minutes);

  /// No description provided for @earlyCheckoutMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String earlyCheckoutMinutes(int minutes);

  /// No description provided for @overtimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String overtimeMinutes(int minutes);

  /// No description provided for @dash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get dash;

  /// No description provided for @readAll.
  ///
  /// In en, this message translates to:
  /// **'Read all'**
  String get readAll;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotificationsYet;

  /// No description provided for @notificationTapToOpen.
  ///
  /// In en, this message translates to:
  /// **'Tap to open'**
  String get notificationTapToOpen;

  /// No description provided for @notificationNoLinkedScreen.
  ///
  /// In en, this message translates to:
  /// **'No linked screen for this alert. Try Leave or History from the menu.'**
  String get notificationNoLinkedScreen;

  /// No description provided for @photoCaptureTitleCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Verify check-in'**
  String get photoCaptureTitleCheckIn;

  /// No description provided for @photoCaptureTitleCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Verify checkout'**
  String get photoCaptureTitleCheckOut;

  /// No description provided for @photoCaptureHint.
  ///
  /// In en, this message translates to:
  /// **'Position your face inside the circle'**
  String get photoCaptureHint;

  /// No description provided for @photoCaptureButton.
  ///
  /// In en, this message translates to:
  /// **'Capture photo'**
  String get photoCaptureButton;

  /// No description provided for @photoRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get photoRetake;

  /// No description provided for @photoUse.
  ///
  /// In en, this message translates to:
  /// **'Use photo'**
  String get photoUse;

  /// No description provided for @photoUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo...'**
  String get photoUploading;

  /// No description provided for @photoCaptureFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not capture photo. Try again.'**
  String get photoCaptureFailed;

  /// No description provided for @photoCameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera access is required to take your verification photo. Allow camera permission and try again.'**
  String get photoCameraPermissionRequired;

  /// No description provided for @photoCameraPermissionWeb.
  ///
  /// In en, this message translates to:
  /// **'Camera access is required. Allow the camera for this site in your browser settings, then try again.'**
  String get photoCameraPermissionWeb;

  /// No description provided for @photoOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get photoOpenSettings;

  /// No description provided for @evaluationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Evaluations'**
  String get evaluationsTitle;

  /// No description provided for @noEvaluationsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get noEvaluationsYet;

  /// No description provided for @evaluationDue.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String evaluationDue(String date);

  /// No description provided for @evaluationSelfAverage.
  ///
  /// In en, this message translates to:
  /// **'Self total: {value}'**
  String evaluationSelfAverage(String value);

  /// No description provided for @evaluationDueCard.
  ///
  /// In en, this message translates to:
  /// **'Complete your {name} review'**
  String evaluationDueCard(String name);

  /// No description provided for @evaluationStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Action needed'**
  String get evaluationStatusOpen;

  /// No description provided for @evaluationStatusWaiting.
  ///
  /// In en, this message translates to:
  /// **'With reviewer'**
  String get evaluationStatusWaiting;

  /// No description provided for @evaluationStatusScored.
  ///
  /// In en, this message translates to:
  /// **'Scored'**
  String get evaluationStatusScored;

  /// No description provided for @evaluationStatusFinal.
  ///
  /// In en, this message translates to:
  /// **'Final'**
  String get evaluationStatusFinal;

  /// No description provided for @evaluationStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get evaluationStatusClosed;

  /// No description provided for @evaluationCycleClosedBanner.
  ///
  /// In en, this message translates to:
  /// **'This evaluation cycle is closed. Your results are shown below.'**
  String get evaluationCycleClosedBanner;

  /// No description provided for @evaluationEvaluatorTotal.
  ///
  /// In en, this message translates to:
  /// **'Evaluator total: {value}'**
  String evaluationEvaluatorTotal(String value);

  /// No description provided for @evaluationStepInfo.
  ///
  /// In en, this message translates to:
  /// **'Employee information'**
  String get evaluationStepInfo;

  /// No description provided for @evaluationStepMetrics.
  ///
  /// In en, this message translates to:
  /// **'Metrics'**
  String get evaluationStepMetrics;

  /// No description provided for @evaluationStepRoles.
  ///
  /// In en, this message translates to:
  /// **'Roles & responsibilities'**
  String get evaluationStepRoles;

  /// No description provided for @evaluationStepSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills improved'**
  String get evaluationStepSkills;

  /// No description provided for @evaluationStepGoals.
  ///
  /// In en, this message translates to:
  /// **'Development goals'**
  String get evaluationStepGoals;

  /// No description provided for @evaluationStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review & submit'**
  String get evaluationStepReview;

  /// No description provided for @evaluationEmployee.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get evaluationEmployee;

  /// No description provided for @evaluationPosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get evaluationPosition;

  /// No description provided for @evaluationSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Direct supervisor'**
  String get evaluationSupervisor;

  /// No description provided for @evaluationPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get evaluationPeriod;

  /// No description provided for @evaluationNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get evaluationNumber;

  /// No description provided for @evaluationPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous: {value}'**
  String evaluationPrevious(String value);

  /// No description provided for @evaluationPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick target date'**
  String get evaluationPickDate;

  /// No description provided for @evaluationCriteria.
  ///
  /// In en, this message translates to:
  /// **'Evaluation criteria'**
  String get evaluationCriteria;

  /// No description provided for @evaluationReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Check your scores, then submit. You cannot change self-scores after submitting.'**
  String get evaluationReviewHint;

  /// No description provided for @evaluationFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus competency'**
  String get evaluationFocus;

  /// No description provided for @evaluationActionPlan.
  ///
  /// In en, this message translates to:
  /// **'Action plan'**
  String get evaluationActionPlan;

  /// No description provided for @evaluationEvaluatorScore.
  ///
  /// In en, this message translates to:
  /// **'Evaluator: {value}'**
  String evaluationEvaluatorScore(String value);

  /// No description provided for @evaluationSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit self-evaluation'**
  String get evaluationSubmit;

  /// No description provided for @evaluationSubmitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Submit your scores to your reviewer? You will not be able to edit them afterwards.'**
  String get evaluationSubmitConfirm;

  /// No description provided for @evaluationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Self-evaluation submitted.'**
  String get evaluationSubmitted;

  /// No description provided for @evaluationIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Rate every area from 1 to 5. Attendance is scored automatically.'**
  String get evaluationIncomplete;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @meetingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Meetings'**
  String get meetingsTitle;

  /// No description provided for @bookMeeting.
  ///
  /// In en, this message translates to:
  /// **'Book room'**
  String get bookMeeting;

  /// No description provided for @noMeetingsYet.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet.'**
  String get noMeetingsYet;

  /// No description provided for @meetingBooked.
  ///
  /// In en, this message translates to:
  /// **'Room booked.'**
  String get meetingBooked;

  /// No description provided for @meetingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled.'**
  String get meetingCancelled;

  /// No description provided for @meetingRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get meetingRoom;

  /// No description provided for @meetingTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get meetingTitle;

  /// No description provided for @meetingNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get meetingNotes;

  /// No description provided for @meetingStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get meetingStart;

  /// No description provided for @meetingEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get meetingEnd;

  /// No description provided for @meetingBusy.
  ///
  /// In en, this message translates to:
  /// **'Already booked'**
  String get meetingBusy;

  /// No description provided for @pickRoom.
  ///
  /// In en, this message translates to:
  /// **'Select a room'**
  String get pickRoom;

  /// No description provided for @confirmCancelMeeting.
  ///
  /// In en, this message translates to:
  /// **'Cancel this booking?'**
  String get confirmCancelMeeting;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChat;

  /// No description provided for @newGroupChat.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get newGroupChat;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createGroup;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Ops team'**
  String get groupNameHint;

  /// No description provided for @groupNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a group name.'**
  String get groupNameRequired;

  /// No description provided for @groupMembersRequired.
  ///
  /// In en, this message translates to:
  /// **'Invite at least one colleague.'**
  String get groupMembersRequired;

  /// No description provided for @groupSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String groupSelectedCount(int count);

  /// No description provided for @chatTabPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get chatTabPersonal;

  /// No description provided for @chatTabGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get chatTabGroup;

  /// No description provided for @chatTabAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get chatTabAdmin;

  /// No description provided for @noChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet.'**
  String get noChatsYet;

  /// No description provided for @noChatsHint.
  ///
  /// In en, this message translates to:
  /// **'Start a private chat with a colleague.'**
  String get noChatsHint;

  /// No description provided for @noGroupChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No group chats yet.'**
  String get noGroupChatsYet;

  /// No description provided for @noGroupChatsHint.
  ///
  /// In en, this message translates to:
  /// **'Create a group and invite colleagues.'**
  String get noGroupChatsHint;

  /// No description provided for @noAdminChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No admin chats yet.'**
  String get noAdminChatsYet;

  /// No description provided for @noAdminChatsHint.
  ///
  /// In en, this message translates to:
  /// **'When an administrator messages you, it will show here.'**
  String get noAdminChatsHint;

  /// No description provided for @searchColleagues.
  ///
  /// In en, this message translates to:
  /// **'Search colleagues'**
  String get searchColleagues;

  /// No description provided for @noColleaguesFound.
  ///
  /// In en, this message translates to:
  /// **'No colleagues found.'**
  String get noColleaguesFound;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @sayHello.
  ///
  /// In en, this message translates to:
  /// **'Say hello to start the conversation.'**
  String get sayHello;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageHint;

  /// No description provided for @contextPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'How are you signing in?'**
  String get contextPickerTitle;

  /// No description provided for @contextPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your account can sign in as more than one role. Choose Employee to use this app.'**
  String get contextPickerSubtitle;

  /// No description provided for @contextSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get contextSuggested;

  /// No description provided for @switchContext.
  ///
  /// In en, this message translates to:
  /// **'Switch role'**
  String get switchContext;

  /// No description provided for @switchToEmployee.
  ///
  /// In en, this message translates to:
  /// **'Use employee'**
  String get switchToEmployee;

  /// No description provided for @nonEmployeeContextBanner.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {role}. Employee features like check-in need the Employee role.'**
  String nonEmployeeContextBanner(String role);

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get updateRequiredTitle;

  /// No description provided for @updateRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'This version is no longer supported. Please update the app to continue.'**
  String get updateRequiredBody;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'A newer version is ready. You can update now or later from the menu.'**
  String get updateAvailableBody;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get updateNow;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @updateOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the download page.'**
  String get updateOpenFailed;

  /// No description provided for @currentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current version: {version}'**
  String currentVersion(String version);

  /// No description provided for @latestVersion.
  ///
  /// In en, this message translates to:
  /// **'Latest version: {version}'**
  String latestVersion(String version);

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Work-Force v{version}'**
  String appVersionLabel(String version);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

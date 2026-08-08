# Flutter Employee App Phases

## F0 — Foundation ✓
- Material 3 theme and design tokens
- Riverpod, GoRouter, Dio
- Secure storage, API error handling
- Feature-first project structure

## F1 — Authentication ✓
- Login with email or employee code
- Access/refresh token storage
- Automatic refresh
- Forced first-password change
- Session restore and logout

## F2 — Dashboard ✓
- Employee home shell
- Current attendance card
- History/leave shortcuts
- Notification badge

## F3 — Attendance ✓
- GPS permission and capture
- Check-in preview
- Geofence result handling
- Late reason bottom sheet
- Final idempotent check-in
- Checkout with required work description

## F4 — History ✓
- Timesheet calendar
- Worksheet calendar
- Day detail cards
- Month navigation and pull-to-refresh
- Server detail fetch for selected days

## F5 — Leave ✓
- Leave summary
- Leave type loading
- Leave request bottom sheet
- Date validation
- Full leave history
- Admin decision reason display
- Pending-request cancellation

## F6 — Notifications + Socket.IO ✓
- Persistent notification list
- Unread badge
- Mark read / read all
- Authenticated Socket.IO connection
- Realtime invalidation of attendance, history and leave providers
- Firebase Messaging device registration
- Foreground local notification display
- Graceful operation when Firebase is not configured

## F7 — Profile ✓
- Account identity
- Roles and permission count
- Change password
- Sign out
- FCM device unregister on explicit sign out

## Next: F8 — QA & Release
- Run `flutter analyze` and tests
- Configure native Firebase files
- Android/iOS notification permission checks
- Integration tests against staging backend
- Deep links from push notifications
- Crash/error monitoring
- Release signing and store builds

## F8 — Quality & Release ✓
- Global offline banner using `connectivity_plus`
- Safe GET-only transient retry interceptor
- Explicit retry UX for server/network error states
- Reusable animated skeleton loading state
- Accessibility semantics for critical attendance/notification actions
- Padded Material tap targets and controlled large-text behavior
- Compact/large device widget smoke tests
- Android/iOS foreground-location and notification permission checklist
- Integration-test harness for app bootstrap/session flow
- Optional Firebase boot controlled by `ENABLE_FIREBASE`
- Development/staging/production environment validation
- Production HTTPS guardrails
- Android App Bundle / iOS IPA release scripts
- Release QA checklist and staging smoke-test process

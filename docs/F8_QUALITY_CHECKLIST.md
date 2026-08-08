# F8 Quality checklist

## Network and error behavior
- [ ] Launch while offline shows the offline banner without crashing.
- [ ] GET history screens expose retry UX after a transient failure.
- [ ] Reconnection allows manual refresh.
- [ ] Check-in/checkout are never automatically replayed by a generic retry interceptor.
- [ ] 401 refresh flow either recovers once or clears the invalid session.

## Loading UX
- [ ] Attendance uses skeleton loading rather than a blocking full-page spinner.
- [ ] Other feature loading states do not hide app navigation unnecessarily.
- [ ] Empty states are distinguishable from loading and error states.

## Accessibility
- [ ] Check-in and checkout expose clear semantic labels.
- [ ] Notification button has tooltip/semantic label.
- [ ] Status is not communicated only by color.
- [ ] Touch targets remain comfortably tappable.
- [ ] UI remains usable with larger system text.
- [ ] Screen-reader order is logical on Login, Home, Leave and History.

## Device sizes
- [ ] 320x568 logical compact device
- [ ] 360x800 Android baseline
- [ ] 390x844 iPhone baseline
- [ ] 430x932 large phone
- [ ] portrait physical Android GPS test
- [ ] portrait physical iPhone notification test

## Permissions
- [ ] Foreground location only
- [ ] No Android background-location permission
- [ ] Clear iOS When-In-Use purpose text
- [ ] Android 13+ notification permission handled
- [ ] iOS Push Notifications + Remote notifications capabilities configured

## Firebase
- [ ] Same Firebase project family as backend Admin SDK
- [ ] Native Android config installed
- [ ] Native iOS config installed
- [ ] APNs configured
- [ ] FCM token reaches backend device endpoint
- [ ] Foreground local notification renders
- [ ] Token refresh updates backend

## Production
- [ ] APP_ENV=production
- [ ] HTTPS API URL
- [ ] HTTPS Socket URL
- [ ] No localhost/emulator production endpoints
- [ ] Release signing secrets outside Git
- [ ] Staging smoke test completed
- [ ] Android AAB generated
- [ ] iOS IPA/archive generated on macOS

# Production release checklist

## Required quality gate

Run on the development machine:

```bash
flutter pub get
flutter format --set-exit-if-changed .
flutter analyze
flutter test
flutter test integration_test
```

Test at minimum:

- compact Android phone (~320 logical px width)
- normal Android phone (~360-390 px)
- large Android/iOS phone (~430 px)
- iPhone simulator/device
- Android physical device with GPS

## Staging build

```bash
flutter run \
  --dart-define=APP_ENV=staging \
  --dart-define=API_BASE_URL=https://staging-api.example.com/api/v1 \
  --dart-define=SOCKET_BASE_URL=https://staging-api.example.com \
  --dart-define=ENABLE_FIREBASE=true
```

## Production behavior

`AppConfig.validate()` rejects production builds when:

- API or Socket URL is not HTTPS
- emulator development host is used
- APP_ENV is invalid

## Android release

Configure signing using local/CI secrets, never commit keystores or passwords.

Then:

```bash
tool/build_release.sh android
```

Expected artifact:

`build/app/outputs/bundle/release/app-release.aab`

## iOS release

Run on macOS with Xcode signing configured:

```bash
tool/build_release.sh ios
```

Then validate/archive/upload through Xcode/App Store Connect according to your signing workflow.

## Release smoke test

Before promotion:

1. Fresh install.
2. Admin-created employee logs in.
3. Forced password change succeeds.
4. Location permission prompt is understandable.
5. Check-in inside the office succeeds.
6. Late-reason path succeeds on staging test schedule.
7. Checkout requires work description.
8. Timesheet/worksheet appears in history.
9. Leave request is visible and decision updates arrive.
10. Push notification reaches a physical device.
11. Logout removes the local session/device registration.
12. Relaunch does not expose another user's data.

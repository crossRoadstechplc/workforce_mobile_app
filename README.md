# Workforce Employee App

Flutter employee client for the workforce time, worksheet and leave platform.

## Status

Phases F0 through F8 are included:

- Foundation and UI system
- Authentication + forced temporary-password change
- Employee dashboard
- Location-based check-in/check-out
- Late-reason workflow
- Timesheet/worksheet history calendars
- Leave request/history/summary
- Persistent notifications
- Socket.IO realtime refresh
- Firebase push integration hooks
- Employee profile/account controls
- Offline/error handling, retries and skeleton states
- Accessibility/device-size quality pass
- Integration-test harness
- Staging/production configuration
- Release build scripts and checklists

## Architecture

```text
lib/
├── app/
├── core/
│   ├── api/
│   ├── auth/
│   ├── config/
│   ├── connectivity/
│   ├── location/
│   ├── notifications/
│   ├── realtime/
│   ├── theme/
│   └── widgets/
└── features/
    ├── auth/
    ├── attendance/
    ├── dashboard/
    ├── history/
    ├── leave/
    ├── notifications/
    └── profile/
```

REST/PostgreSQL remain the source of truth. Socket.IO only triggers realtime refreshes of Riverpod state.

## Create native platform folders

This scaffold intentionally does not fabricate machine-generated Android/iOS projects. On the Flutter workstation run:

```bash
./tool/bootstrap_platforms.sh
```

or:

```bash
flutter create --platforms=android,ios .
flutter pub get
```

Then follow:

- `docs/PLATFORM_PERMISSIONS.md`
- `docs/FIREBASE_SETUP.md`
- `docs/RELEASE.md`

## Local development

Android emulator:

```bash
flutter run \
  --dart-define=APP_ENV=development \
  --dart-define=API_BASE_URL=http://10.0.2.2:4000/api/v1 \
  --dart-define=SOCKET_BASE_URL=http://10.0.2.2:4000 \
  --dart-define=ENABLE_FIREBASE=false
```

iOS simulator:

```bash
flutter run \
  --dart-define=APP_ENV=development \
  --dart-define=API_BASE_URL=http://localhost:4000/api/v1 \
  --dart-define=SOCKET_BASE_URL=http://localhost:4000 \
  --dart-define=ENABLE_FIREBASE=false
```

## Staging

Use a real HTTPS staging backend and Firebase test project/configuration:

```bash
flutter run \
  --dart-define=APP_ENV=staging \
  --dart-define=API_BASE_URL=https://staging-api.example.com/api/v1 \
  --dart-define=SOCKET_BASE_URL=https://staging-api.example.com \
  --dart-define=ENABLE_FIREBASE=true
```

## Production safeguards

`AppConfig.validate()` rejects invalid environment names and blocks production startup when API/Socket endpoints do not use HTTPS.

The client automatically retries only safe GET requests for transient failures. Attendance, leave, password and other mutations are not automatically replayed.

## Quality gate

Run before release:

```bash
flutter pub get
flutter format --set-exit-if-changed .
flutter analyze
flutter test
flutter test integration_test
```

## Release

Linux/macOS shell:

```bash
export API_BASE_URL=https://api.example.com/api/v1
export SOCKET_BASE_URL=https://api.example.com
./tool/build_release.sh android
```

Windows PowerShell:

```powershell
$env:API_BASE_URL='https://api.example.com/api/v1'
$env:SOCKET_BASE_URL='https://api.example.com'
./tool/build_release.ps1 android
```

Use `ios` instead of `android` on macOS for the iOS archive flow.

## Environment limitation for this generated handoff

Flutter/Dart is not installed in the execution environment used to prepare this scaffold, so native generation, `flutter analyze`, tests and release builds must be executed on the Flutter workstation.

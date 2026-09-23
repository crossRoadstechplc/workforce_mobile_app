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
- Chrome narrow viewport (<840 — drawer shell)
- Chrome wide viewport (≥840 — permanent sidebar, centered content ≤960px)

## Staging build

```bash
flutter run \
  --dart-define=APP_ENV=staging \
  --dart-define=API_BASE_URL=https://staging-api.example.com/api/v1 \
  --dart-define=SOCKET_BASE_URL=https://staging-api.example.com \
  --dart-define=ENABLE_FIREBASE=true
```

## Web local smoke test

Use `localhost` (not `10.0.2.2`) when running in Chrome:

```bash
flutter run -d chrome \
  --dart-define=APP_ENV=development \
  --dart-define=API_BASE_URL=http://localhost:4000/api/v1 \
  --dart-define=SOCKET_BASE_URL=http://localhost:4000 \
  --dart-define=ENABLE_FIREBASE=false
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

Expected Play Store artifact:

`build/app/outputs/bundle/release/app-release.aab`

### GitHub APK (employee sideload / in-app update)

Bump `pubspec.yaml` version and `.env` `APP_VERSION` together (example `1.1.0`), then:

```powershell
$env:APP_VERSION="1.1.0"
.\tool\build_release.ps1 apk
```

```bash
export APP_VERSION=1.1.0
tool/build_release.sh apk
```

Artifact: `build/app/outputs/flutter-apk/app-release.apk`

Publish it:

```bash
git tag v1.1.0
git push origin v1.1.0
gh release create v1.1.0 build/app/outputs/flutter-apk/app-release.apk --title "Work-Force Android 1.1.0"
```

Then point the API at that release (restart/reload after editing `.env`):

```env
ANDROID_APP_VERSION=1.1.0
ANDROID_FORCE_UPDATE=false
ANDROID_RELEASE_URL=https://github.com/crossRoadstechplc/workforce_mobile_app/releases/download/v1.1.0/app-release.apk
```

`FORCE=false` shows a dismissible sidebar banner. `FORCE=true` blocks the app with a required-update modal. The installed APK reads `APP_VERSION` from dart-defines and compares it with `GET /api/v1/app/version`.

## iOS release

Run on macOS with Xcode signing configured:

```bash
tool/build_release.sh ios
```

Then validate/archive/upload through Xcode/App Store Connect according to your signing workflow.

## Web release (Firebase Hosting)

1. Set `.firebaserc` project id (`firebase use <project-id>`).
2. Ensure the backend CORS allowlist includes the Hosting origin (`https://<project>.web.app` and any custom domain).
3. Build:

```bash
# PowerShell
$env:API_BASE_URL="https://api.example.com/api/v1"
$env:SOCKET_BASE_URL="https://api.example.com"
$env:ENABLE_FIREBASE="false"   # set true after flutterfire configure for web push
.\tool\build_release.ps1 web
```

```bash
# bash
export API_BASE_URL=https://api.example.com/api/v1
export SOCKET_BASE_URL=https://api.example.com
export ENABLE_FIREBASE=false
tool/build_release.sh web
```

Expected artifact: `build/web`

4. Deploy:

```bash
firebase deploy --only hosting
```

`firebase.json` rewrites all routes to `/index.html` so `go_router` deep links work after refresh.

Invite handoff: the admin portal can open `workforce://login?email=` (custom scheme) or `{EMPLOYEE_WEB_URL}/login?email=`. Native builds register the `workforce` scheme; web uses the query prefill on `/login`.

5. Post-deploy checks:

- Desktop and phone browser on the Hosting URL
- Hard-refresh `/home`, `/history`, `/chat/...`
- Geolocation and camera (HTTPS only)

See `docs/FIREBASE_SETUP.md` for web app / FlutterFire push setup.

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
13. (Web) Wide layout shows sidebar; content stays centered.
14. (Web) Deep link refresh does not 404.

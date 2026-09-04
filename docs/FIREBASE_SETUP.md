# Firebase setup

Firebase is optional in development and explicit in release builds.

## 1. Create Firebase applications

Create Android, iOS, and (for web push / Hosting project alignment) Web apps in the same Firebase project used by the backend Firebase Admin SDK.

Android package name and iOS bundle identifier must match the identifiers generated/configured for this Flutter project.

## 2. Configure FlutterFire

After running `flutter create --platforms=android,ios,web .`, install the FlutterFire CLI and run:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This creates the platform Firebase configuration and generates `lib/firebase_options.dart` (replacing the stub checked into the repo).

`bootstrap.dart` and `PushNotificationService` pass `DefaultFirebaseOptions.currentPlatform` into `Firebase.initializeApp`. If generated options are missing, init falls back to native `google-services.json` / `GoogleService-Info.plist`, then fails soft (so Hosting can ship with `ENABLE_FIREBASE=false`).

## 3. Android

Place/configure the generated Firebase Android configuration under the Android app module and verify the Google Services Gradle plugin is applied by FlutterFire.

Create the notification channel used by the app if you customize Android notification behavior:

- channel id: `workforce_general`
- name: `Workforce notifications`

## 4. iOS

Add the generated `GoogleService-Info.plist` to the Runner target.

In Xcode enable:

- Push Notifications
- Background Modes -> Remote notifications

Upload/configure the APNs authentication key in Firebase Cloud Messaging.

## 5. Web

### Hosting (static Flutter web)

The app ships `firebase.json` with `public: build/web` and SPA rewrites to `/index.html`.

```bash
npm i -g firebase-tools
firebase login
firebase use <your-project-id>   # updates .firebaserc

flutter build web --release \
  --dart-define=APP_ENV=production \
  --dart-define=API_BASE_URL=https://api.example.com/api/v1 \
  --dart-define=SOCKET_BASE_URL=https://api.example.com \
  --dart-define=ENABLE_FIREBASE=false

firebase deploy --only hosting
```

Allow the Hosting origin on the Express + Socket.IO CORS allowlist. Production API/Socket URLs must be HTTPS.

### Web push (optional)

1. Add a Web app in the Firebase Console.
2. Run `flutterfire configure` so `lib/firebase_options.dart` includes web.
3. Configure a Web Push certificate / VAPID key in Cloud Messaging.
4. Rebuild and host with `--dart-define=ENABLE_FIREBASE=true`.

Foreground local notifications via `flutter_local_notifications` are skipped on web; the browser / FCM handles delivery.

## 6. Runtime flag

Development without Firebase:

```bash
flutter run --dart-define=ENABLE_FIREBASE=false
```

Configured environment:

```bash
flutter run --dart-define=ENABLE_FIREBASE=true
```

Production native release should set `ENABLE_FIREBASE=true` once the native configuration is present. Web Hosting may keep it `false` until FlutterFire web options and VAPID are ready.

## 7. Backend alignment

The Express backend must use the same Firebase project. Device tokens are registered through the existing `/notifications/devices` API.

Never place Firebase Admin private keys in the Flutter application.

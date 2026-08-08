# Firebase setup

Firebase is optional in development and explicit in release builds.

## 1. Create Firebase applications

Create Android and iOS apps in the same Firebase project used by the backend Firebase Admin SDK.

Android package name and iOS bundle identifier must match the identifiers generated/configured for this Flutter project.

## 2. Configure FlutterFire

After running `flutter create --platforms=android,ios .`, install the FlutterFire CLI and run:

```bash
flutterfire configure
```

This creates the platform Firebase configuration and normally generates `lib/firebase_options.dart`.

The current app can also initialize from native `google-services.json` / `GoogleService-Info.plist`. If your team chooses generated `firebase_options.dart`, update `bootstrap.dart` and `PushNotificationService` to pass `DefaultFirebaseOptions.currentPlatform` consistently.

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

## 5. Runtime flag

Development without Firebase:

```bash
flutter run --dart-define=ENABLE_FIREBASE=false
```

Configured environment:

```bash
flutter run --dart-define=ENABLE_FIREBASE=true
```

Production release should set `ENABLE_FIREBASE=true` once the native configuration is present.

## 6. Backend alignment

The Express backend must use the same Firebase project. Device tokens are registered through the existing `/notifications/devices` API.

Never place Firebase Admin private keys in the Flutter application.

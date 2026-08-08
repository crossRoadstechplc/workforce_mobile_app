# Android and iOS permission review

The employee app uses foreground location for check-in/check-out and notifications. It does not require continuous/background location.

## Android

After generating Android files, verify `android/app/src/main/AndroidManifest.xml` contains foreground location permissions:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

For Android 13+ notification permission, Firebase Messaging / local notifications require notification permission handling. Verify:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

Do **not** add `ACCESS_BACKGROUND_LOCATION` for the current product requirements.

Production checks:

- application label is correct
- package/application id is final
- release signing is configured outside Git
- cleartext traffic is not enabled for production
- min/target SDK satisfy current plugin requirements

## iOS

In `ios/Runner/Info.plist`, add a clear foreground-location purpose string:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Your location is used only when you check in or check out to verify that you are at the approved office.</string>
```

Do not request Always Location permission.

For notifications:

- enable Push Notifications capability
- enable Background Modes -> Remote notifications
- configure APNs through Firebase

Production checks:

- bundle identifier is final
- team/signing configuration is correct
- permission copy matches actual app behavior
- privacy disclosures mention attendance location usage

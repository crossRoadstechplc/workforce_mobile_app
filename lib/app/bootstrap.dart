import 'package:firebase_core/firebase_core.dart';

import '../core/config/app_config.dart';
import '../core/preferences/app_preferences.dart';
import '../firebase_options.dart';

Future<AppPreferences> bootstrap() async {
  AppConfig.validate();

  if (AppConfig.enableFirebase) {
    await _initializeFirebase();
  }

  return await AppPreferences.load();
}

/// Prefer generated [DefaultFirebaseOptions] (required for web). Fall back to
/// platform-native config for Android/iOS when options are not generated yet.
Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    try {
      await Firebase.initializeApp();
    } catch (_) {
      // Fail soft: Hosting deploys can ship with ENABLE_FIREBASE=false,
      // or native config may be missing during local development.
    }
  }
}

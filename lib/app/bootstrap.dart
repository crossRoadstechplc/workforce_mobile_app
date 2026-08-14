import 'package:firebase_core/firebase_core.dart';

import '../core/config/app_config.dart';
import '../core/preferences/app_preferences.dart';

Future<AppPreferences> bootstrap() async {
  AppConfig.validate();

  if (AppConfig.enableFirebase) {
    await Firebase.initializeApp();
  }

  return await AppPreferences.load();
}

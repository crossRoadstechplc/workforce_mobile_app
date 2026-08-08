import 'package:firebase_core/firebase_core.dart';

import '../core/config/app_config.dart';

Future<void> bootstrap() async {
  AppConfig.validate();

  // Firebase remains optional in development/staging until platform config
  // files are present. Production should enable it explicitly.
  if (AppConfig.enableFirebase) {
    await Firebase.initializeApp();
  }
}

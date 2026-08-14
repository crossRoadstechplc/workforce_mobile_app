import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';
import 'core/preferences/app_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await bootstrap();
  runApp(
    ProviderScope(
      overrides: [
        appPreferencesProvider.overrideWithValue(preferences),
      ],
      child: const WorkforceEmployeeApp(),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/locale_controller.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_mode_controller.dart';
import '../core/widgets/offline_banner.dart';
import '../features/notifications/application/notification_controller.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';

class WorkforceEmployeeApp extends ConsumerWidget {
  const WorkforceEmployeeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(realtimeCoordinatorProvider);
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp.router(
      title: 'Workforce',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(locale),
      darkTheme: AppTheme.dark(locale),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) => OfflineBanner(
        child: MediaQuery.withClampedTextScaling(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.5,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}

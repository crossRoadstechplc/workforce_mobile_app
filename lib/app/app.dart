import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/offline_banner.dart';
import '../features/notifications/application/notification_controller.dart';
import 'router.dart';

class WorkforceEmployeeApp extends ConsumerWidget {
  const WorkforceEmployeeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(realtimeCoordinatorProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Workforce',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
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

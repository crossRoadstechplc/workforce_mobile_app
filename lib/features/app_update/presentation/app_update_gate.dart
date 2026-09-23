import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/app_update_controller.dart';
import 'force_update_overlay.dart';

class AppUpdateGate extends ConsumerStatefulWidget {
  const AppUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends ConsumerState<AppUpdateGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(appUpdateControllerProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showForce = ref.watch(appUpdateControllerProvider.select((s) => s.showForceModal));
    return PopScope(
      canPop: !showForce,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (showForce) const ForceUpdateOverlay(),
        ],
      ),
    );
  }
}

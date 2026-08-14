import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connectivity/network_status.dart';
import '../localization/l10n_extensions.dart';
import '../theme/app_theme_extension.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(networkStatusProvider);
    final isOffline = status.value == false;
    final colors = context.appColors;

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          child: isOffline
              ? Semantics(
                  liveRegion: true,
                  label: context.l10n.offlineMessage,
                  child: Container(
                    width: double.infinity,
                    color: colors.warning,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              context.l10n.offlineBannerDetail,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Expanded(child: child),
      ],
    );
  }
}

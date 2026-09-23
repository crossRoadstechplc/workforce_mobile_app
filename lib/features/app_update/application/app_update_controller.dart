import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../../../core/preferences/app_preferences.dart';
import '../data/app_version_models.dart';
import '../data/app_version_repository.dart';
import '../data/semver.dart';

final appVersionRepositoryProvider = Provider<AppVersionRepository>(
  (ref) => AppVersionRepository(ref.watch(dioProvider)),
);

final appUpdateControllerProvider =
    NotifierProvider<AppUpdateController, AppUpdateState>(AppUpdateController.new);

class AppUpdateController extends Notifier<AppUpdateState> {
  @override
  AppUpdateState build() {
    unawaited(refresh());
    return const AppUpdateState();
  }

  Future<void> refresh() async {
    if (kIsWeb) return;
    try {
      final remote = await ref.read(appVersionRepositoryProvider).fetch();
      if (remote.androidVersion.isEmpty) return;
      final mismatch = compareSemver(AppConfig.appVersion, remote.androidVersion) != 0;
      final dismissed = ref.read(appPreferencesProvider).isUpdateDismissed(remote.androidVersion);
      state = AppUpdateState(
        remote: remote,
        kind: !mismatch
            ? AppUpdateKind.none
            : remote.forceUpdate
                ? AppUpdateKind.forced
                : AppUpdateKind.optional,
        dismissed: dismissed,
      );
    } catch (_) {
      // Offline or unreachable: never block the app on a failed check.
    }
  }

  Future<void> dismissOptional() async {
    final remote = state.remote;
    if (remote == null || state.kind != AppUpdateKind.optional) return;
    await ref.read(appPreferencesProvider).setUpdateDismissed(remote.androidVersion);
    state = AppUpdateState(remote: remote, kind: AppUpdateKind.optional, dismissed: true);
  }

  Future<bool> openRelease() async {
    final url = state.remote?.releaseUrl;
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

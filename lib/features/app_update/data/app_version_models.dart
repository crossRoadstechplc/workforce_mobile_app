class AppVersionInfo {
  const AppVersionInfo({
    required this.androidVersion,
    required this.forceUpdate,
    this.releaseUrl,
  });

  final String androidVersion;
  final bool forceUpdate;
  final String? releaseUrl;

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    final map = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final url = map['releaseUrl']?.toString().trim();
    return AppVersionInfo(
      androidVersion: (map['androidVersion'] ?? '').toString().trim(),
      forceUpdate: map['forceUpdate'] == true,
      releaseUrl: url == null || url.isEmpty ? null : url,
    );
  }
}

enum AppUpdateKind { none, optional, forced }

class AppUpdateState {
  const AppUpdateState({
    this.remote,
    this.kind = AppUpdateKind.none,
    this.dismissed = false,
  });

  final AppVersionInfo? remote;
  final AppUpdateKind kind;
  final bool dismissed;

  bool get showForceModal => kind == AppUpdateKind.forced;
  bool get showSidebarBanner => kind == AppUpdateKind.optional && !dismissed;
}

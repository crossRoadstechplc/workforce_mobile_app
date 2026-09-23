import 'package:flutter_test/flutter_test.dart';
import 'package:workforce_employee_app/features/app_update/data/app_version_models.dart';
import 'package:workforce_employee_app/features/app_update/data/semver.dart';

void main() {
  group('compareSemver', () {
    test('treats equal versions as zero', () {
      expect(compareSemver('1.0.0', '1.0.0'), 0);
      expect(compareSemver('1.2', '1.2.0'), 0);
    });

    test('detects older and newer versions', () {
      expect(compareSemver('1.0.0', '1.1.0'), lessThan(0));
      expect(compareSemver('1.2.0', '1.1.9'), greaterThan(0));
      expect(compareSemver('2.0.0', '1.9.9'), greaterThan(0));
    });

    test('ignores build metadata', () {
      expect(compareSemver('1.1.0+4', '1.1.0'), 0);
    });
  });

  group('AppVersionInfo', () {
    test('parses a flat backend payload', () {
      final info = AppVersionInfo.fromJson({
        'platform': 'ANDROID',
        'androidVersion': '1.1.0',
        'forceUpdate': true,
        'releaseUrl': 'https://github.com/crossRoadstechplc/workforce_mobile_app/releases/latest',
      });
      expect(info.androidVersion, '1.1.0');
      expect(info.forceUpdate, isTrue);
      expect(info.releaseUrl, contains('github.com'));
    });

    test('treats empty releaseUrl as null', () {
      final info = AppVersionInfo.fromJson({
        'androidVersion': '1.0.0',
        'forceUpdate': false,
        'releaseUrl': '',
      });
      expect(info.releaseUrl, isNull);
    });
  });

  group('AppUpdateState', () {
    test('force mismatch cannot be dismissed', () {
      const state = AppUpdateState(
        remote: AppVersionInfo(androidVersion: '1.1.0', forceUpdate: true),
        kind: AppUpdateKind.forced,
        dismissed: true,
      );
      expect(state.showForceModal, isTrue);
      expect(state.showSidebarBanner, isFalse);
    });

    test('optional mismatch can be dismissed from the sidebar', () {
      const visible = AppUpdateState(
        remote: AppVersionInfo(androidVersion: '1.1.0', forceUpdate: false),
        kind: AppUpdateKind.optional,
      );
      const dismissed = AppUpdateState(
        remote: AppVersionInfo(androidVersion: '1.1.0', forceUpdate: false),
        kind: AppUpdateKind.optional,
        dismissed: true,
      );
      expect(visible.showSidebarBanner, isTrue);
      expect(dismissed.showSidebarBanner, isFalse);
    });
  });
}

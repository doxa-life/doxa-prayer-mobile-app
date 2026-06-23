import 'package:doxa_prayer_mobile_app/services/update_controller.dart';
import 'package:doxa_prayer_mobile_app/services/version_check_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  // The decision logic that drives which banner (if any) shows.
  group('resolveUpdateState', () {
    test('no prompt when current == latest', () {
      expect(
        resolveUpdateState(
          currentVersion: '1.2.0',
          latestVersion: '1.2.0',
          minSupportedVersion: '1.0.0',
        ),
        UpdateState.none,
      );
    });

    test('no prompt when current is newer than latest', () {
      expect(
        resolveUpdateState(
          currentVersion: '2.0.0',
          latestVersion: '1.2.0',
          minSupportedVersion: '1.0.0',
        ),
        UpdateState.none,
      );
    });

    test('optional when current < latest but >= min', () {
      expect(
        resolveUpdateState(
          currentVersion: '1.1.0',
          latestVersion: '1.2.0',
          minSupportedVersion: '1.0.0',
        ),
        UpdateState.optional,
      );
    });

    test('forced when current < min', () {
      expect(
        resolveUpdateState(
          currentVersion: '1.0.0',
          latestVersion: '1.2.0',
          minSupportedVersion: '1.1.0',
        ),
        UpdateState.forced,
      );
    });

    test('forced takes precedence over optional', () {
      expect(
        resolveUpdateState(
          currentVersion: '0.9.0',
          latestVersion: '1.2.0',
          minSupportedVersion: '1.0.0',
        ),
        UpdateState.forced,
      );
    });

    test('optional suppressed when this exact version was dismissed', () {
      expect(
        resolveUpdateState(
          currentVersion: '1.1.0',
          latestVersion: '1.2.0',
          minSupportedVersion: '1.0.0',
          dismissedVersion: '1.2.0',
        ),
        UpdateState.none,
      );
    });

    test('dismissing an older version does not suppress a newer optional', () {
      expect(
        resolveUpdateState(
          currentVersion: '1.1.0',
          latestVersion: '1.2.0',
          minSupportedVersion: '1.0.0',
          dismissedVersion: '1.1.5',
        ),
        UpdateState.optional,
      );
    });

    test('dismissal never suppresses a forced update', () {
      expect(
        resolveUpdateState(
          currentVersion: '1.0.0',
          latestVersion: '1.2.0',
          minSupportedVersion: '1.1.0',
          dismissedVersion: '1.2.0',
        ),
        UpdateState.forced,
      );
    });

    test('optional suppressed while snoozed', () {
      expect(
        resolveUpdateState(
          currentVersion: '1.1.0',
          latestVersion: '1.2.0',
          minSupportedVersion: '1.0.0',
          optionalSnoozed: true,
        ),
        UpdateState.none,
      );
    });

    test('snooze never suppresses a forced update', () {
      expect(
        resolveUpdateState(
          currentVersion: '1.0.0',
          latestVersion: '1.2.0',
          minSupportedVersion: '1.1.0',
          optionalSnoozed: true,
        ),
        UpdateState.forced,
      );
    });

    test('build/pre-release suffixes are ignored in comparison', () {
      expect(
        resolveUpdateState(
          currentVersion: '1.2.0+5',
          latestVersion: '1.2.0',
          minSupportedVersion: '1.0.0',
        ),
        UpdateState.none,
      );
    });

    test('compares numerically, not lexically (1.2.0 < 1.10.0)', () {
      expect(
        resolveUpdateState(
          currentVersion: '1.2.0',
          latestVersion: '1.10.0',
          minSupportedVersion: '1.0.0',
        ),
        UpdateState.optional,
      );
    });
  });

  group('dismissOptionalUpdate', () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });
    tearDown(() => updateController.value = UpdateStatus.none);

    test('clears the banner and remembers the dismissed version', () async {
      const info = AppVersionInfo(
        latestVersion: '1.2.0',
        minSupportedVersion: '1.0.0',
        androidPlayUrl: 'https://play.google.com/store',
      );
      updateController.value = const UpdateStatus(UpdateState.optional, info);

      await dismissOptionalUpdate();

      expect(updateController.value.state, UpdateState.none);
      // Key mirrors _dismissedVersionKey in update_controller.dart.
      final prefs = SharedPreferencesAsync();
      expect(await prefs.getString('update_dismissed_version'), '1.2.0');
    });
  });
}

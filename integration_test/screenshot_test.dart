// Store-screenshot capture harness (ANDROID).
//
// Drives the REAL app (via `main()`) on an emulator, seeds a known state so every
// screen looks populated and deterministic, and calls `binding.takeScreenshot`
// on each. The bytes are written to disk by test_driver/screenshot_driver.dart
// when run under `flutter drive`.
//
// The seeded state and the ordered screen list live in the shared scenario
// module (test_driver/screenshot_scenario.dart) so this harness and the iOS one
// (test_driver/screenshot_ios_app.dart) can never drift. This file owns only the
// Android-specific bits: the GL-surface conversion and the pump-based settle.
//
// Run it through the tooling, never by hand:
//   tool/screenshots/capture_android.sh      (Android emulators, this machine)
//   tool/screenshots/capture_ios.sh          (iOS simulators, macOS only)
//
// Point the app at staging by building with `--flavor staging` (see ApiConfig).

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart' show WidgetsApp;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:doxa_prayer_mobile_app/main.dart' as app;

import '../test_driver/screenshot_scenario.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // iOS simulators force a debug build (no AOT), which would otherwise paint the
  // "DEBUG" ribbon over every marketing shot. Suppress it app-wide; a no-op in
  // profile/release, so it's harmless for the Android profile capture too.
  WidgetsApp.debugAllowBannerOverride = false;

  testWidgets('capture store screenshots', (tester) async {
    await seedState();

    // Android renders to a GL surface the host can't read; convert it to an
    // image-backed surface first. iOS captures directly and has no equivalent.
    if (!kIsWeb && Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    await app.main();
    installOverlayGuards();
    await _settle(tester);

    for (final step in screenshotScenario) {
      await step.go();
      await _settle(tester, network: step.network);
      await tester.pump();
      await binding.takeScreenshot(step.name);
    }
  }, timeout: const Timeout(Duration(minutes: 5)));
}

/// Pump for a bounded window so real async (HTTP, image decode) can complete.
/// We avoid `pumpAndSettle` because loading spinners never settle and would
/// throw. [network] screens get a longer window for the fetch + images.
Future<void> _settle(WidgetTester tester, {bool network = false}) async {
  final window = network
      ? const Duration(seconds: 12)
      : const Duration(seconds: 3);
  final end = DateTime.now().add(window);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

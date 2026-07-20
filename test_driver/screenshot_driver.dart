// Host-side driver for the screenshot capture harness.
//
// Runs on the dev machine (not the device) while `flutter drive` executes
// integration_test/screenshot_test.dart. Each `binding.takeScreenshot(name)`
// call in the test invokes onScreenshot here with the PNG bytes, which we write
// to $SCREENSHOT_OUT/<name>.png.
//
// The capture scripts set SCREENSHOT_OUT to a per-device folder
// (e.g. build/screenshots_raw/android_phone) so runs don't clobber each other.

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final outDir = Platform.environment['SCREENSHOT_OUT'] ??
      'build/screenshots_raw/default';

  // This driver is the ANDROID path: it writes the exact bytes each
  // `binding.takeScreenshot(name)` captured on-device, at the moment of the shot.
  //
  // It is NOT used for iOS. On iOS the Flutter surface omits the system status
  // bar (a separate system window), and integration_test doesn't call this
  // callback per-shot anyway — it collects every screenshot and replays them
  // here in one batch AFTER the test finishes. So there is no way to re-capture
  // "the current screen" from here at the right moment. iOS therefore uses a
  // host-driven flutter_driver harness (test_driver/screenshot_ios_driver.dart +
  // screenshot_ios_app.dart) that grabs the full device screen — real status bar
  // included — with `xcrun simctl io screenshot` between navigation steps.
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final dir = Directory(outDir);
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final file = File('${dir.path}/$name.png');
      await file.writeAsBytes(bytes, flush: true);
      stdout.writeln('  saved ${file.path} (${bytes.length} bytes)');
      return true;
    },
  );
}

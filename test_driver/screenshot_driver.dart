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

  // On iOS, `binding.takeScreenshot` captures only the Flutter surface, which
  // excludes the system status bar (clock/signal/wifi/battery — a separate
  // system window since iOS 13), leaving the top strip blank. When CAPTURE_UDID
  // is set (see capture_ios.sh), we instead grab the FULL device screen with
  // `xcrun simctl io … screenshot`, which includes the status bar the iOS
  // simulator draws (pinned to 9:41 / full bars by `simctl status_bar override`).
  // The takeScreenshot call still fires this callback at the right moment — we
  // just discard its bytes and re-capture. Android leaves CAPTURE_UDID unset and
  // keeps using the Flutter bytes.
  final captureUdid = Platform.environment['CAPTURE_UDID'];

  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final dir = Directory(outDir);
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final file = File('${dir.path}/$name.png');

      if (captureUdid != null && captureUdid.isNotEmpty) {
        final r = await Process.run(
          'xcrun',
          ['simctl', 'io', captureUdid, 'screenshot', file.path],
        );
        if (r.exitCode != 0) {
          stderr.writeln('  simctl io screenshot failed for $name: ${r.stderr}');
          return false;
        }
        stdout.writeln('  saved ${file.path} (full-screen via simctl)');
        return true;
      }

      await file.writeAsBytes(bytes, flush: true);
      stdout.writeln('  saved ${file.path} (${bytes.length} bytes)');
      return true;
    },
  );
}

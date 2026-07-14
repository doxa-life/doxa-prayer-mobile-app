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

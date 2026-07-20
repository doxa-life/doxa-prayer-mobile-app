// iOS store-screenshot HOST driver (the `flutter drive --driver`).
//
// Runs on the Mac (not the simulator) while screenshot_ios_app.dart runs the app
// on the booted simulator. It walks the scenario one step at a time: ask the app
// to advance (`requestData('next')` -> the app navigates, settles and returns the
// shot name), then capture the FULL device screen — including the real, pinned
// status bar — with `xcrun simctl io <udid> screenshot`. Repeats until the app
// reports 'done'.
//
// Env (set by tool/screenshots/capture_ios.sh):
//   SCREENSHOT_OUT  per-device raw output dir (e.g. build/screenshots_raw/ios_iphone69)
//   CAPTURE_UDID    the booted simulator to screenshot

import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';

Future<void> main() async {
  final outDir = Platform.environment['SCREENSHOT_OUT'] ??
      'build/screenshots_raw/default';
  final udid = Platform.environment['CAPTURE_UDID'];
  if (udid == null || udid.isEmpty) {
    stderr.writeln(
      'CAPTURE_UDID is required (the simulator UDID to screenshot). '
      'Run via tool/screenshots/capture_ios.sh.',
    );
    exit(1);
  }

  final dir = Directory(outDir);
  if (!dir.existsSync()) dir.createSync(recursive: true);

  final driver = await FlutterDriver.connect();
  try {
    while (true) {
      final name = await driver.requestData('next');
      if (name == 'done') break;

      final path = '${dir.path}/$name.png';
      final r = await Process.run(
        'xcrun',
        ['simctl', 'io', udid, 'screenshot', path],
      );
      if (r.exitCode != 0) {
        stderr.writeln('  simctl io screenshot failed for $name: ${r.stderr}');
      } else {
        stdout.writeln('  saved $path (full-screen + real status bar via simctl)');
      }
    }
  } finally {
    await driver.close();
  }
}

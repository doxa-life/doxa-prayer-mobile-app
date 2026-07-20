// iOS store-screenshot driver APP (the `flutter drive --target`).
//
// Runs the REAL app on a booted iOS simulator and exposes a flutter_driver
// extension so the HOST driver (screenshot_ios_driver.dart) can walk it screen
// by screen. After each navigation settles, the host grabs the FULL device
// screen with `xcrun simctl io … screenshot`, which — unlike the Flutter-surface
// capture used on Android — includes the real, system-rendered status bar
// (pinned to 9:41 / full bars by `simctl status_bar override` in capture_ios.sh).
//
// Why host-driven and not integration_test's binding.takeScreenshot: on iOS
// native, integration_test batches every screenshot and replays them to the
// driver only AFTER the test finishes, so a `simctl` grab from that callback
// always captures the LAST screen. Driving from the host lets the capture happen
// while the app is actually on each screen.
//
// The handler is a simple cursor over `screenshotScenario`: each `requestData`
// advances one step, navigates, waits out a settle budget, and returns the shot
// name for the host to save as `<name>.png`; when the list is exhausted it
// returns 'done' so the host loop stops.

import 'dart:async';

import 'package:flutter/widgets.dart' show WidgetsApp;
import 'package:flutter_driver/driver_extension.dart';

import 'package:doxa_prayer_mobile_app/main.dart' as app;

import 'screenshot_scenario.dart';

// Longer budget for screens whose hero image / list is fetched over the network;
// short one for purely-local screens. Real wall-clock waits (this is a live app,
// not a WidgetTester) so HTTP + image decode genuinely finish before the grab.
const _networkSettle = Duration(seconds: 12);
const _localSettle = Duration(seconds: 3);

Future<void> main() async {
  // enableFlutterDriverExtension() installs its OWN binding, so it must be the
  // FIRST binding-touching call in main() — calling WidgetsFlutterBinding
  // .ensureInitialized() (directly, or transitively via seedState's platform
  // channel) beforehand makes the extension's binding constructor assert
  // "Binding is already initialized to WidgetsFlutterBinding".
  //
  // The host may connect and start sending commands before app.main() has run
  // runApp() and attached appRouter, so the handler waits on [appReady] before
  // navigating.
  final appReady = Completer<void>();
  var index = 0;

  enableFlutterDriverExtension(
    handler: (String? command) async {
      await appReady.future;

      // Re-arm the overlay guards on every step: late async bootstrap keeps
      // trying to re-show the banners, so a one-shot set on the first step
      // wouldn't hold for the later screens.
      installOverlayGuards();

      if (index >= screenshotScenario.length) return 'done';
      final step = screenshotScenario[index++];
      await step.go();
      await Future<void>.delayed(step.network ? _networkSettle : _localSettle);
      return step.name;
    },
  );

  // iOS simulators force a debug build (no AOT), which would otherwise paint the
  // "DEBUG" ribbon over every marketing shot. Suppress it app-wide.
  WidgetsApp.debugAllowBannerOverride = false;

  // Seed persisted state BEFORE app.main() so its load* bootstrap picks it up.
  // (Safe now: the driver extension's binding is already up for the channel.)
  await seedState();

  await app.main();
  appReady.complete();
}

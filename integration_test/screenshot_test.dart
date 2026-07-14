// Store-screenshot capture harness.
//
// Drives the REAL app (via `main()`) on a device/emulator, seeds a known state
// so every screen looks populated and deterministic, and calls
// `binding.takeScreenshot(name)` on each. The bytes are written to disk by
// test_driver/screenshot_driver.dart when run under `flutter drive`.
//
// Run it through the tooling, never by hand:
//   tool/screenshots/capture_android.sh      (Android emulators, this machine)
//   tool/screenshots/capture_ios.sh          (iOS simulators, macOS only)
//
// Point the app at staging by building with `--flavor staging` (see ApiConfig).
// State is seeded into SharedPreferences BEFORE main() runs, so the app's own
// load* bootstrap picks it up: wizard complete, English, a selected people
// group ("afar"), and two reminders.

import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb, ValueNotifier;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:doxa_prayer_mobile_app/main.dart' as app;
import 'package:doxa_prayer_mobile_app/router.dart';
import 'package:doxa_prayer_mobile_app/services/prayer_reminder_controller.dart';
import 'package:doxa_prayer_mobile_app/services/reminders_notifications.dart';
import 'package:doxa_prayer_mobile_app/services/update_controller.dart';
import 'package:doxa_prayer_mobile_app/services/wizard_completion_controller.dart';

/// A real staging people group with an image, a full profile and daily prayer
/// content — see tool/screenshots/README.md for how it was chosen.
const _slug = 'afar';
const _name = 'Afar';
const _imageUrl =
    'https://media.joshuaproject.net/public/assets/media/profiles/photos/p11486.jpg';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture store screenshots', (tester) async {
    await _seedState();

    // Android renders to a GL surface the host can't read; convert it to an
    // image-backed surface first. iOS captures directly and has no equivalent.
    if (!kIsWeb && Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    await app.main();
    _installOverlayGuards();
    await _settle(tester);

    // 1) Onboarding — the app booted straight to /wizard because we seeded
    //    wizard_completed=false. Captured first, while still un-onboarded.
    await _shot(tester, binding, '06_onboarding');

    // Completing onboarding flips wizardCompletedController; the router's
    // refreshListenable redirects /wizard -> /home. network:true — the home
    // hero image is a network image and must finish loading before the shot.
    await markWizardCompleted();
    await _settle(tester, network: true);
    await _shot(tester, binding, '01_home');

    // 2) Pray — the seeded selected group drives a real staging prayer session;
    //    give the network fetch + hero image time to load before snapping.
    appRouter.go('/pray');
    await _settle(tester, network: true);
    await _shot(tester, binding, '02_pray');

    // 3) People groups list — fetched from staging.
    appRouter.go('/people-groups');
    await _settle(tester, network: true);
    await _shot(tester, binding, '03_people_groups');

    // 4) People group detail profile.
    appRouter.go('/people-groups/$_slug');
    await _settle(tester, network: true);
    await _shot(tester, binding, '04_people_group_details');

    // 5) Reminders — the two seeded reminders.
    appRouter.go('/reminders');
    await _settle(tester);
    await _shot(tester, binding, '05_reminders');
  }, timeout: const Timeout(Duration(minutes: 5)));
}

/// Seed persisted state so main()'s load* bootstrap makes each screen look
/// populated. Written via SharedPreferencesAsync — the same backend the app
/// uses — so keys/values line up exactly.
Future<void> _seedState() async {
  final prefs = SharedPreferencesAsync();
  // Start un-onboarded so the wizard is capturable, then complete it in-test.
  await prefs.setBool('wizard_completed', false);
  await prefs.setString('app_locale_language_code', 'en');
  await prefs.setString('selected_people_group_slug', _slug);
  await prefs.setString('selected_people_group_name', _name);
  await prefs.setString('selected_people_group_image_url', _imageUrl);
  // Two reminders: every-morning + Mon/Wed/Fri evening (weekday: Mon=1..Sun=7).
  await prefs.setString(
    'reminders',
    jsonEncode(<Map<String, dynamic>>[
      {
        'id': 'shot-morning',
        'hour': 7,
        'minute': 30,
        'weekdays': [1, 2, 3, 4, 5, 6, 7],
        'enabled': true,
      },
      {
        'id': 'shot-evening',
        'hour': 20,
        'minute': 0,
        'weekdays': [1, 3, 5],
        'enabled': true,
      },
    ]),
  );
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

/// Permanently suppress the transient / permission-driven overlays that would
/// otherwise clutter a marketing shot. These are driven by global notifiers
/// that async bootstrap checks flip on *after* startup — e.g.
/// refreshNotificationsBlocked() resolving late on a slow emulator re-shows the
/// "Notifications are turned off" banner. A one-shot set isn't enough, so each
/// guard re-pins its notifier whenever something tries to change it:
///   - update-gate banner/modal (checkForAppUpdate)
///   - home "Ready for today's prayer?" nudge
///   - Reminders notifications-blocked / exact-alarms-not-allowed warnings
void _installOverlayGuards() {
  void pin(ValueNotifier<bool> n, bool target) {
    n.value = target;
    n.addListener(() {
      if (n.value != target) n.value = target;
    });
  }

  pin(notificationsBlocked, false);
  pin(exactAlarmsBlocked, false);
  pin(prayerReminderDismissedController, true);

  updateController.value = UpdateStatus.none;
  updateController.addListener(() {
    if (updateController.value.state != UpdateState.none) {
      updateController.value = UpdateStatus.none;
    }
  });
}

Future<void> _shot(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  String name,
) async {
  await tester.pump();
  await binding.takeScreenshot(name);
}

// Shared store-screenshot scenario — the single source of truth for the seeded
// state, the transient-overlay guards, and the ordered list of screens to shoot.
//
// Imported by BOTH capture harnesses so they can never drift:
//   * integration_test/screenshot_test.dart  (Android — Flutter-surface bytes)
//   * test_driver/screenshot_ios_app.dart     (iOS — real full-screen simctl grab)
//
// It deliberately imports NEITHER `integration_test` NOR `flutter_driver`: those
// belong to the two callers. Here we only touch app code + SharedPreferences so
// the file is safe to pull into either entrypoint. How each caller *settles*
// between navigation and capture differs (pump loop vs. wall-clock delay) and
// stays in the caller; the `network` flag just tells it which budget to use.

import 'dart:convert';

import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:doxa_prayer_mobile_app/router.dart';
import 'package:doxa_prayer_mobile_app/services/prayer_reminder_controller.dart';
import 'package:doxa_prayer_mobile_app/services/reminders_notifications.dart';
import 'package:doxa_prayer_mobile_app/services/update_controller.dart';
import 'package:doxa_prayer_mobile_app/services/wizard_completion_controller.dart';

/// A real staging people group with an image, a full profile and daily prayer
/// content — see tool/screenshots/README.md for how it was chosen.
const _slug = 'adi';
const _name = 'Adi';
const _imageUrl =
    'https://media.joshuaproject.net/public/assets/media/profiles/photos/p18386.jpg';

/// One captured screen: the file base name (also its store-ordering prefix), the
/// navigation that brings it on screen, and whether it needs the longer settle
/// budget (network fetch + hero image decode).
class ShotStep {
  const ShotStep(this.name, this.go, {this.network = false});

  final String name;
  final Future<void> Function() go;
  final bool network;
}

/// The scenario in CAPTURE order — onboarding first, because the app boots to
/// `/wizard` while `wizard_completed=false` is seeded. Completing the wizard
/// flips `wizardCompletedController`, whose router `refreshListenable` redirects
/// `/wizard` -> `/home`; the rest are plain `appRouter.go(...)` jumps.
///
/// NB: this is not the on-disk/store order (see SHOT_ORDER in config.sh); files
/// keep their numeric prefixes, only the driving sequence starts with onboarding.
final List<ShotStep> screenshotScenario = <ShotStep>[
  // 1) Onboarding — still un-onboarded, so the wizard is showing.
  ShotStep('06_onboarding', () async {}),
  // 2) Home — complete onboarding; the redirect lands us on /home. The hero is a
  //    network image, so this needs the longer settle.
  ShotStep('01_home', markWizardCompleted, network: true),
  // 3) Pray — the seeded selected group drives a real staging prayer session.
  ShotStep('02_pray', () async => appRouter.go('/pray'), network: true),
  // 4) People groups list — fetched from staging.
  ShotStep(
    '03_people_groups',
    () async => appRouter.go('/people-groups'),
    network: true,
  ),
  // 5) People group detail profile.
  ShotStep(
    '04_people_group_details',
    () async => appRouter.go('/people-groups/$_slug'),
    network: true,
  ),
  // 6) Reminders — the two seeded reminders (no network).
  ShotStep('05_reminders', () async => appRouter.go('/reminders')),
];

/// Seed persisted state so main()'s load* bootstrap makes each screen look
/// populated. Written via SharedPreferencesAsync — the same backend the app
/// uses — so keys/values line up exactly. Must run BEFORE app.main().
Future<void> seedState() async {
  final prefs = SharedPreferencesAsync();
  // Start un-onboarded so the wizard is capturable, then complete it in-run.
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

/// Permanently suppress the transient / permission-driven overlays that would
/// otherwise clutter a marketing shot. These are driven by global notifiers that
/// async bootstrap checks flip on *after* startup — e.g.
/// refreshNotificationsBlocked() resolving late on a slow device re-shows the
/// "Notifications are turned off" banner. A one-shot set isn't enough, so each
/// guard re-pins its notifier whenever something tries to change it:
///   - update-gate banner/modal (checkForAppUpdate)
///   - home "Ready for today's prayer?" nudge
///   - Reminders notifications-blocked / exact-alarms-not-allowed warnings
///
/// Idempotent: safe to call repeatedly (the iOS harness re-arms it per step).
void installOverlayGuards() {
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

// Shared store-screenshot scenario — the single source of truth for the seeded
// state, the transient-overlay guards, and the ordered list of screens to shoot.
//
// Imported by BOTH capture harnesses so they can never drift:
//   * integration_test/screenshot_test.dart  (Android — Flutter-surface bytes)
//   * test_driver/screenshot_ios_app.dart     (iOS — real full-screen simctl grab)
//
// It deliberately imports NEITHER `integration_test` NOR `flutter_driver`: those
// belong to the two callers. Here we only touch app code + SharedPreferences so
// the file is safe to pull into either entrypoint. How each caller *waits out* a
// settle budget differs (pump loop vs. wall-clock delay) and stays in the
// caller; each step's `settle` only says how long that wait should be.

import 'dart:convert';

import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:doxa_prayer_mobile_app/router.dart';
import 'package:doxa_prayer_mobile_app/services/prayer_reminder_controller.dart';
import 'package:doxa_prayer_mobile_app/services/reminders_notifications.dart';
import 'package:doxa_prayer_mobile_app/services/update_controller.dart';
import 'package:doxa_prayer_mobile_app/services/wizard_completion_controller.dart';

/// How long a screen gets to finish loading before the shutter. Named here so
/// both harnesses wait for the same lengths.
const Duration localSettle = Duration(seconds: 3);
const Duration networkSettle = Duration(seconds: 12);

/// The map needs its own, longer budget: on top of the pin data it waits on
/// Mapbox raster tiles, a couple of dozen requests that only begin once the
/// camera has fitted itself to the focus group. A half-drawn basemap is an
/// obvious blemish in a store shot.
const Duration mapSettle = Duration(seconds: 25);

/// One subscribed people group in the seeded state. Mirrors the JSON shape of
/// `SubscribedPeopleGroup` (subscribed_people_groups_controller.dart);
/// `subscriptionId` is left out because nothing we capture reads it.
class _Group {
  const _Group(this.slug, this.name, this.imageUrl);

  final String slug;
  final String name;
  final String imageUrl;

  Map<String, dynamic> toJson() => {
    'slug': slug,
    'name': name,
    'imageUrl': imageUrl,
  };
}

/// Three real staging people groups, each with a photo, a full profile and
/// daily prayer content. Three rather than one so the home carousel reads as
/// the multi-group one v2 made it, and rather than the cap of five so the cards
/// aren't cut off mid-shot.
///
/// They are also neighbours in the eastern Himalaya, within ~4° of each other,
/// which is what makes the map shot work: it opens fitted to [_focusSlug], and
/// the other two fall inside that view as subscribed hearts rather than leaving
/// a lone pin in an empty region.
const _groups = <_Group>[
  _Group(
    'adi',
    'Adi',
    'https://media.joshuaproject.net/public/assets/media/profiles/photos/p18386.jpg',
  ),
  _Group(
    'khamba',
    'Khamba',
    'https://media.joshuaproject.net/public/assets/media/profiles/photos/p18522.jpg',
  ),
  _Group(
    'dzalakha',
    'Dzalakha',
    'https://media.joshuaproject.net/public/assets/media/profiles/photos/p19267.jpg',
  ),
];

/// The active group: what the Pray tab opens on, whose profile `04_…` shows,
/// and what the map centres on.
const _focusSlug = 'adi';

/// One captured screen: the file base name (also its store-ordering prefix), the
/// navigation that brings it on screen, and how long to let it settle before the
/// shutter.
class ShotStep {
  const ShotStep(this.name, this.go, {this.settle = localSettle});

  final String name;
  final Future<void> Function() go;
  final Duration settle;
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
  ShotStep('07_onboarding', () async {}),
  // 2) Home — complete onboarding; the redirect lands us on /home. Every
  //    carousel card carries a network photo, so this needs the longer settle.
  ShotStep('01_home', markWizardCompleted, settle: networkSettle),
  // 3) Pray — the active group drives a real staging prayer session.
  ShotStep('02_pray', () async => appRouter.go('/pray'), settle: networkSettle),
  // 4) People groups list — fetched from staging.
  ShotStep(
    '03_people_groups',
    () async => appRouter.go('/people-groups'),
    settle: networkSettle,
  ),
  // 5) People group detail profile.
  ShotStep(
    '04_people_group_details',
    () async => appRouter.go('/people-groups/$_focusSlug'),
    settle: networkSettle,
  ),
  // 6) Map — new in v2; in the app it opens from a home card's map button, but
  //    the route is a sibling of the details one, so we can go straight to it.
  //    The pin data is already warm from step 4's list fetch (the decode
  //    publishes every group's coordinates); the basemap tiles are not.
  ShotStep(
    '05_map',
    () async => appRouter.go('/people-groups/$_focusSlug/map'),
    settle: mapSettle,
  ),
  // 7) Reminders — the seeded per-group reminders (no network).
  ShotStep('06_reminders', () async => appRouter.go('/reminders')),
];

/// Seed persisted state so main()'s load* bootstrap makes each screen look
/// populated. Written via SharedPreferencesAsync — the same backend the app
/// uses — so keys/values line up exactly. Must run BEFORE app.main().
Future<void> seedState() async {
  final prefs = SharedPreferencesAsync();
  // Start un-onboarded so the wizard is capturable, then complete it in-run.
  await prefs.setBool('wizard_completed', false);
  await prefs.setString('app_locale_language_code', 'en');
  // The v2 keys: the subscription list, plus which of them is active. Written
  // directly rather than through the legacy single-selection keys, whose
  // migration would only ever produce a one-card carousel.
  await prefs.setString(
    'people_group_subscriptions',
    jsonEncode([for (final g in _groups) g.toJson()]),
  );
  await prefs.setString('active_people_group_slug', _focusSlug);
  // Reminders belong to a group in v2, so seed two different groups' reminders
  // — every-morning and Mon/Wed/Fri evening — and the screen shows both of its
  // per-group sections. (weekday: Mon=1..Sun=7.)
  await prefs.setString(
    'reminders',
    jsonEncode(<Map<String, dynamic>>[
      {
        'id': 'shot-morning',
        'slug': _groups[0].slug,
        'hour': 7,
        'minute': 30,
        'weekdays': [1, 2, 3, 4, 5, 6, 7],
        'enabled': true,
      },
      {
        'id': 'shot-evening',
        'slug': _groups[1].slug,
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

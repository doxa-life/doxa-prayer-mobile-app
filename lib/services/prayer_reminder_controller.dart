import 'package:flutter/foundation.dart';

import 'prayer_history_service.dart';
import 'subscribed_people_groups_controller.dart';

/// People groups whose "haven't prayed yet today" nudge the user has waved away
/// during the current app session — with the "×", or by tapping through to the
/// Pray tab.
///
/// Per group rather than a single flag: someone praying for several groups who
/// dismisses the nudge for one should still be nudged about the others.
///
/// Intentionally in-memory only (no `SharedPreferences`): a fresh app launch
/// starts empty, so the nudge reappears on the next restart if the user still
/// hasn't prayed. Dismissal only silences it for the running session.
final ValueNotifier<Set<String>> prayerReminderDismissedController =
    ValueNotifier<Set<String>>(<String>{});

void dismissPrayerReminder(String slug) =>
    prayerReminderDismissedController.value = {
      ...prayerReminderDismissedController.value,
      slug,
    };

/// The people group to nudge the user about, or null when there is nothing to
/// nudge: the first subscription that still needs today's prayer. Groups
/// already prayed for today, and ones dismissed this session, are skipped — so
/// praying for one group hands the nudge on to the next rather than silencing
/// it for the day.
///
/// Subscription order, not the active group: the nudge works down the list the
/// home carousel shows, in the same order every time, so which group it asks
/// for next doesn't depend on whichever card the user last happened to open.
SubscribedPeopleGroup? peopleGroupNeedingPrayer() {
  final prayed = prayedTodayController.value;
  final dismissed = prayerReminderDismissedController.value;

  for (final g in peopleGroupsController.value.list) {
    if (!prayed.contains(g.slug) && !dismissed.contains(g.slug)) return g;
  }
  return null;
}

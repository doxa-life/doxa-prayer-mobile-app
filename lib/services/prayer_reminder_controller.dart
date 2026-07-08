import 'package:flutter/foundation.dart';

/// Whether the user has dismissed the "haven't prayed yet today" home banner
/// during the current app session.
///
/// Intentionally in-memory only (no `SharedPreferences`): a fresh app launch
/// starts at `false`, so the banner reappears on the next restart if the user
/// still hasn't prayed. Dismissal only silences it for the running session.
final ValueNotifier<bool> prayerReminderDismissedController =
    ValueNotifier<bool>(false);

void dismissPrayerReminder() => prayerReminderDismissedController.value = true;

import 'dart:developer' as developer;

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_localizations.dart';
import 'api_config.dart';
import 'crash_reporting_service.dart';
import 'locale_controller.dart';
import 'reminders_controller.dart';
import 'subscribed_people_groups_controller.dart';

const String _androidChannelId = 'prayer_reminders';
const String _androidChannelName = 'Prayer Reminders';
const String _androidChannelDescription = 'Scheduled reminders to pray.';

final FlutterLocalNotificationsPlugin _plugin =
    FlutterLocalNotificationsPlugin();

/// Native bridge for clearing the iOS app-icon badge. flutter_local_notifications
/// can only *set* a badge (via [DarwinNotificationDetails.badgeNumber]); it has
/// no API to reset it, so the AppDelegate hosts a tiny `clearBadge` handler.
const MethodChannel _badgeChannel = MethodChannel('app.prayer.doxa/badge');

/// Native → Dart channel over which the iOS AppDelegate forwards reminder
/// notification taps (see ios/Runner/AppDelegate.swift). Needed because, under
/// this app's UIScene / implicit-engine setup, flutter_local_notifications'
/// own tap callback never fires on iOS — the plugin isn't on the app-lifecycle
/// list FlutterAppDelegate forwards UNUserNotificationCenter events to.
const MethodChannel _notificationTapChannel = MethodChannel(
  'app.prayer.doxa/notifications',
);

bool _initialized = false;

/// Notifier that publishes the payload of a tapped reminder notification.
/// The app shell listens to this and routes accordingly. Set to null after
/// the route has been consumed.
final ValueNotifier<String?> reminderTapPayload = ValueNotifier<String?>(null);

/// true when OS notification permission is denied — drives "needs attention"
/// badges on the Reminders tab and the Settings row.
final ValueNotifier<bool> notificationsBlocked = ValueNotifier<bool>(false);

/// true when the app can post notifications but cannot schedule *exact* alarms
/// (Android 12+ without the SCHEDULE_EXACT_ALARM permission). Reminders still
/// fire in this state, but via inexact scheduling so they may arrive several
/// minutes late — the reminders screen surfaces a warning offering to grant it.
/// Always false on iOS and Android < 12, where exact scheduling isn't gated.
final ValueNotifier<bool> exactAlarmsBlocked = ValueNotifier<bool>(false);

/// Refreshes [notificationsBlocked] from the current OS permission state.
Future<void> refreshNotificationsBlocked() async {
  notificationsBlocked.value = !(await notificationsAuthorized());
}

/// Refreshes [exactAlarmsBlocked] from the current OS permission state.
Future<void> refreshExactAlarmsBlocked() async {
  exactAlarmsBlocked.value = !(await exactAlarmsAuthorized());
}

/// Attempts to enable notifications. Tries a real permission request first: on a
/// device that hasn't been asked yet this shows the system popup (iOS and
/// Android 13+). If the user previously chose "Don't allow", the OS returns
/// without a dialog and we fall back to opening the app's notification settings
/// so they can flip it on manually. Returns whether permission is now granted,
/// and keeps [notificationsBlocked] in sync on the success path.
Future<bool> promptEnableNotifications() async {
  final granted = await ensureNotificationPermission();
  if (granted) {
    notificationsBlocked.value = false;
    return true;
  }
  await AppSettings.openAppSettings(type: AppSettingsType.notification);
  return false;
}

/// Clears the iOS app-icon badge left by a delivered reminder. Call when the
/// app comes to the foreground: opening the app means the user has "seen" the
/// waiting reminder. No-op on Android (launcher notification dots clear on their
/// own when the notification is tapped or dismissed) and on web.
Future<void> clearNotificationBadge() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;
  try {
    await _badgeChannel.invokeMethod<void>('clearBadge');
  } catch (e) {
    debugPrint('reminders_notifications: clearBadge failed: $e');
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // Top-level handler required by flutter_local_notifications. The app may not
  // be alive yet; routing is handled by the foreground listener once the app
  // is up. We seed the payload notifier so the foreground side picks it up.
  developer.log(
    'notificationTapBackground (bg isolate) fired: '
    'payload=${response.payload}, actionId=${response.actionId}',
    name: 'REMINDER_TAP',
  );
  reminderTapPayload.value = response.payload;
}

void _onTap(NotificationResponse response) {
  developer.log(
    '_onTap (foreground/warm-resume) fired: '
    'payload=${response.payload}, actionId=${response.actionId}, '
    'notifierBefore=${reminderTapPayload.value}',
    name: 'REMINDER_TAP',
  );
  reminderTapPayload.value = response.payload;
}

Future<void> initRemindersNotifications() async {
  if (_initialized) return;
  tz.initializeTimeZones();
  // tz.initializeTimeZones() leaves tz.local set to UTC; set it to the
  // device's actual zone so scheduled times match what the user picked.
  try {
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
  } catch (e) {
    debugPrint('reminders_notifications: failed to resolve local zone: $e');
  }

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  // Don't request iOS permission here — we ask lazily on first reminder save.
  const iosInit = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  await _plugin.initialize(
    settings: const InitializationSettings(android: androidInit, iOS: iosInit),
    onDidReceiveNotificationResponse: _onTap,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  // Create the Android notification channel up-front. On Android 8+, posting
  // to a non-existent channel silently drops the notification.
  final android = _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  await android?.createNotificationChannel(
    const AndroidNotificationChannel(
      _androidChannelId,
      _androidChannelName,
      description: _androidChannelDescription,
      importance: Importance.high,
    ),
  );

  // iOS bridge: the AppDelegate forwards notification taps here (see the doc on
  // [_notificationTapChannel]). Seed the same notifier the shell listens to, so
  // routing is identical to the plugin's own (Android) tap path.
  _notificationTapChannel.setMethodCallHandler((call) async {
    if (call.method == 'reminderTapped') {
      final payload = call.arguments as String?;
      developer.log(
        'native bridge reminderTapped: payload=$payload',
        name: 'REMINDER_TAP',
      );
      reminderTapPayload.value = payload;
    }
    return null;
  });

  // Cold-start: if the app was launched by tapping a notification, seed the
  // payload notifier so the shell can route once it's mounted.
  final launch = await _plugin.getNotificationAppLaunchDetails();
  developer.log(
    'getNotificationAppLaunchDetails: '
    'didLaunchApp=${launch?.didNotificationLaunchApp}, '
    'payload=${launch?.notificationResponse?.payload}',
    name: 'REMINDER_TAP',
  );
  if (launch?.didNotificationLaunchApp ?? false) {
    reminderTapPayload.value = launch?.notificationResponse?.payload;
  }

  // Reschedule when the user changes locale so notification copy follows.
  localeController.addListener(_onLocaleChanged);

  _initialized = true;
}

void _onLocaleChanged() {
  final list = remindersController.value?.list ?? const <Reminder>[];
  // Fire-and-forget — ValueNotifier listeners are sync, scheduling is async.
  rescheduleAllReminders(list);
}

/// Asks the OS for permission to post notifications. Returns whether the
/// permission is currently granted (after the prompt, if shown).
Future<bool> ensureNotificationPermission() async {
  if (!_initialized) await initRemindersNotifications();

  final android = _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  if (android != null) {
    final granted = await android.requestNotificationsPermission();
    if (granted ?? false) await _nudgeOneSignalRegister();
    return granted ?? false;
  }

  final ios = _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();
  if (ios != null) {
    final granted = await ios.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (granted ?? false) await _nudgeOneSignalRegister();
    return granted ?? false;
  }

  return true;
}

/// After the shared OS notification permission has been granted via the
/// reminders flow, nudge OneSignal to register its APNs/FCM token immediately.
/// Because permission is already granted, this shows NO second dialog — it just
/// opts the push subscription in so the device becomes addressable right away.
/// Coupling is intentionally one-directional (reminders → OneSignal).
Future<void> _nudgeOneSignalRegister() async {
  if (!ApiConfig.hasOneSignal) return;
  try {
    await OneSignal.Notifications.requestPermission(false);
  } catch (e) {
    debugPrint(
      'reminders_notifications: OneSignal permission nudge failed: $e',
    );
  }
}

/// Returns whether notifications are currently authorised, WITHOUT prompting.
/// Used by the settings screen to show permission status; unlike
/// [ensureNotificationPermission] it never triggers a system dialog.
Future<bool> notificationsAuthorized() async {
  if (!_initialized) await initRemindersNotifications();

  final android = _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  if (android != null) {
    return (await android.areNotificationsEnabled()) ?? false;
  }

  final ios = _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();
  if (ios != null) {
    return (await ios.checkPermissions())?.isEnabled ?? false;
  }

  return true;
}

/// Returns whether the app may schedule *exact* alarms, WITHOUT prompting.
/// Only Android 12+ gates this; the plugin reports true on older Android and on
/// platforms (iOS) where exact scheduling isn't permission-controlled, so a
/// false result specifically means "Android that needs SCHEDULE_EXACT_ALARM but
/// hasn't been granted it".
Future<bool> exactAlarmsAuthorized() async {
  if (!_initialized) await initRemindersNotifications();

  final android = _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  if (android != null) {
    return (await android.canScheduleExactNotifications()) ?? true;
  }

  // iOS and other platforms deliver scheduled notifications at the set time
  // without an exact-alarm permission, so there is nothing to be blocked on.
  return true;
}

/// Sends the user to the system "Alarms & reminders" screen to grant the
/// SCHEDULE_EXACT_ALARM permission (no-op on iOS / Android < 12). Reschedules
/// afterwards so already-set reminders upgrade from inexact to exact timing,
/// and keeps [exactAlarmsBlocked] in sync. Returns whether exact alarms are now
/// permitted.
Future<bool> promptEnableExactAlarms() async {
  if (!_initialized) await initRemindersNotifications();

  final android = _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  if (android != null) {
    await android.requestExactAlarmsPermission();
  }

  final granted = await exactAlarmsAuthorized();
  exactAlarmsBlocked.value = !granted;
  if (granted) {
    await rescheduleAllReminders(
      remindersController.value?.list ?? const <Reminder>[],
    );
  }
  return granted;
}

/// Cancels every scheduled reminder notification and reschedules one per
/// distinct (people group, weekday, hour, minute) slot across all enabled
/// reminders.
///
/// The slug is part of the key on purpose. Two reminders for the *same* group
/// at the same time still collapse into a single alert — they mean the same
/// thing. Two *different* groups at the same time do not: each names its own
/// group and deep-links into its own prayer, so both are delivered.
Future<void> rescheduleAllReminders(List<Reminder> all) async {
  if (!_initialized) await initRemindersNotifications();
  await _plugin.cancelAll();

  final slots = reminderNotificationSlots(all);
  if (slots.isEmpty) return;

  // Prefer exact alarms so reminders fire at the chosen minute, but fall back
  // to inexact scheduling when the permission isn't granted — otherwise the
  // plugin throws ExactAlarmPermissionException and nothing gets scheduled at
  // all. Also refresh the notifier so the warning banner reflects reality.
  final canExact = await exactAlarmsAuthorized();
  exactAlarmsBlocked.value = !canExact;
  final scheduleMode = canExact
      ? AndroidScheduleMode.exactAllowWhileIdle
      : AndroidScheduleMode.inexactAllowWhileIdle;

  final l = lookupAppLocalizations(localeController.value);
  final title = l.reminderNotificationTitle;

  final androidDetails = AndroidNotificationDetails(
    _androidChannelId,
    _androidChannelName,
    channelDescription: _androidChannelDescription,
    importance: Importance.high,
    priority: Priority.high,
  );
  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    // iOS only puts a badge on the app icon when a notification carries a
    // badge number — presentBadge alone does nothing without it. Local
    // notifications can't increment, so every reminder sets the badge to 1
    // ("something's waiting"); it's cleared when the app next opens
    // (see clearNotificationBadge, called from AppShell).
    badgeNumber: 1,
  );
  final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

  for (final entry in slots.entries) {
    final id = entry.key;
    final slot = entry.value;
    final fireAt = _nextInstanceOf(slot.weekday, slot.hour, slot.minute);
    // Naming the group is what makes a stack of same-minute reminders
    // readable; a reminder whose group has since been removed falls back to
    // the generic copy rather than showing a blank name.
    final name = peopleGroupsController.value.bySlug(slot.slug)?.name;
    final body = name == null
        ? l.reminderNotificationBody
        : l.reminderNotificationBodyForGroup(name);
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: fireAt,
        notificationDetails: details,
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        // The tapped notification routes to this group's prayer, so the slug
        // travels with it.
        payload: slot.slug,
      );
    } catch (e, s) {
      debugPrint('reminders_notifications: schedule failed for $id: $e');
      reportError(e, s, reason: 'reminder schedule failed');
    }
  }
}

/// One scheduled notification. Several reminders can share a slot; only the
/// group, weekday and time survive into what is actually delivered.
typedef ReminderSlot = ({String slug, int weekday, int hour, int minute});

/// The distinct notification slots across every enabled reminder, keyed by the
/// id each will be scheduled under. Same-group duplicates collapse because
/// they land on the same key; different groups at the same minute do not.
@visibleForTesting
Map<int, ReminderSlot> reminderNotificationSlots(List<Reminder> all) {
  final slots = <int, ReminderSlot>{};
  for (final r in all) {
    if (!r.enabled) continue;
    for (final weekday in r.weekdays) {
      slots[_notificationId(r.slug, weekday, r.hour, r.minute)] = (
        slug: r.slug,
        weekday: weekday,
        hour: r.hour,
        minute: r.minute,
      );
    }
  }
  return slots;
}

/// Maps a (people group, weekday, hour, minute) slot to a stable notification
/// id. Reminders for the same group at the same fire time share an id, so only
/// one notification is scheduled for them; different groups get different ids
/// and are delivered alongside each other.
///
/// Bit layout, all positive and well inside the 32-bit ids the platforms
/// accept: slugHash<<14 | hour<<9 | minute<<3 | weekday, where slugHash is 13
/// bits — so the whole id stays under 2^27.
int _notificationId(String slug, int weekday, int hour, int minute) {
  final time = (hour << 9) | (minute << 3) | (weekday & 0x7);
  return (_slugHash(slug) << 14) | time;
}

/// A 13-bit FNV-1a hash of the slug. Deliberately not `String.hashCode`, which
/// Dart does not promise to keep stable between runs — these ids are what a
/// later cancel has to match.
///
/// A collision between two slugs would merge their notifications at the same
/// minute; at five subscriptions out of 8192 buckets that is remote, and the
/// cost if it happened is one alert instead of two.
int _slugHash(String slug) {
  var hash = 0x811c9dc5;
  for (final unit in slug.codeUnits) {
    hash = ((hash ^ unit) * 0x01000193) & 0x7fffffff;
  }
  return hash & 0x1fff;
}

/// Fixed id for the debug test notification, well outside the small
/// (weekday, hour, minute) slot-id range so it never collides with a real
/// reminder. See [scheduleTestReminderNotification].
const int _testNotificationId = 999999;

/// DEBUG ONLY: schedules a one-off reminder-style notification [inSeconds] out
/// so the notification-tap → Pray-tab routing can be exercised without waiting
/// for a real scheduled reminder. Uses the exact same channel, details, and
/// `'pray'` payload as a genuine reminder, so the tap code path is identical.
/// Trigger it from the Debug screen, then background the app before it fires.
Future<void> scheduleTestReminderNotification({int inSeconds = 10}) async {
  if (!_initialized) await initRemindersNotifications();

  final l = lookupAppLocalizations(localeController.value);
  final androidDetails = AndroidNotificationDetails(
    _androidChannelId,
    _androidChannelName,
    channelDescription: _androidChannelDescription,
    importance: Importance.high,
    priority: Priority.high,
  );
  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    badgeNumber: 1,
  );
  final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

  final fireAt = tz.TZDateTime.now(tz.local).add(Duration(seconds: inSeconds));
  final canExact = await exactAlarmsAuthorized();
  await _plugin.zonedSchedule(
    id: _testNotificationId,
    title: l.reminderNotificationTitle,
    body: l.reminderNotificationBody,
    scheduledDate: fireAt,
    notificationDetails: details,
    androidScheduleMode: canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle,
    payload: 'pray',
  );
  developer.log(
    'scheduleTestReminderNotification: id=$_testNotificationId scheduled for '
    '$fireAt (in ${inSeconds}s), payload=pray',
    name: 'REMINDER_TAP',
  );
}

tz.TZDateTime _nextInstanceOf(int weekday, int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );
  // Advance day-by-day until we land on the target weekday in the future.
  while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
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

const String _androidChannelId = 'prayer_reminders';
const String _androidChannelName = 'Prayer Reminders';
const String _androidChannelDescription =
    'Scheduled reminders to pray.';

final FlutterLocalNotificationsPlugin _plugin =
    FlutterLocalNotificationsPlugin();

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

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // Top-level handler required by flutter_local_notifications. The app may not
  // be alive yet; routing is handled by the foreground listener once the app
  // is up. We seed the payload notifier so the foreground side picks it up.
  debugPrint('REMINDER_TAP: notificationTapBackground payload=${response.payload}');
  reminderTapPayload.value = response.payload;
}

void _onTap(NotificationResponse response) {
  debugPrint('REMINDER_TAP: _onTap (foreground) payload=${response.payload}');
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
  final android = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await android?.createNotificationChannel(
    const AndroidNotificationChannel(
      _androidChannelId,
      _androidChannelName,
      description: _androidChannelDescription,
      importance: Importance.high,
    ),
  );

  // Cold-start: if the app was launched by tapping a notification, seed the
  // payload notifier so the shell can route once it's mounted.
  final launch = await _plugin.getNotificationAppLaunchDetails();
  debugPrint(
    'REMINDER_TAP: launch details '
    'didLaunch=${launch?.didNotificationLaunchApp} '
    'payload=${launch?.notificationResponse?.payload}',
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

  final android = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  if (android != null) {
    final granted = await android.requestNotificationsPermission();
    if (granted ?? false) await _nudgeOneSignalRegister();
    return granted ?? false;
  }

  final ios = _plugin.resolvePlatformSpecificImplementation<
      IOSFlutterLocalNotificationsPlugin>();
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
    debugPrint('reminders_notifications: OneSignal permission nudge failed: $e');
  }
}

/// Returns whether notifications are currently authorised, WITHOUT prompting.
/// Used by the settings screen to show permission status; unlike
/// [ensureNotificationPermission] it never triggers a system dialog.
Future<bool> notificationsAuthorized() async {
  if (!_initialized) await initRemindersNotifications();

  final android = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  if (android != null) {
    return (await android.areNotificationsEnabled()) ?? false;
  }

  final ios = _plugin.resolvePlatformSpecificImplementation<
      IOSFlutterLocalNotificationsPlugin>();
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

  final android = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
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

  final android = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
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

/// Cancels every scheduled reminder notification and reschedules exactly one
/// per distinct fire-time across all enabled reminders. Keying notifications by
/// time slot (not by reminder) means several reminders that land on the same
/// weekday + time collapse into a single notification — no duplicate alerts.
Future<void> rescheduleAllReminders(List<Reminder> all) async {
  if (!_initialized) await initRemindersNotifications();
  await _plugin.cancelAll();

  // Distinct (weekday, hour, minute) slots across every enabled reminder,
  // keyed by the slot id so duplicates collapse.
  final slots = <int, ({int weekday, int hour, int minute})>{};
  for (final r in all) {
    if (!r.enabled) continue;
    for (final weekday in r.weekdays) {
      slots[_notificationId(weekday, r.hour, r.minute)] =
          (weekday: weekday, hour: r.hour, minute: r.minute);
    }
  }
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
  final body = l.reminderNotificationBody;

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
  );
  final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

  for (final entry in slots.entries) {
    final id = entry.key;
    final slot = entry.value;
    final fireAt = _nextInstanceOf(slot.weekday, slot.hour, slot.minute);
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: fireAt,
        notificationDetails: details,
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: 'pray',
      );
    } catch (e, s) {
      debugPrint('reminders_notifications: schedule failed for $id: $e');
      reportError(e, s, reason: 'reminder schedule failed');
    }
  }
}

/// Debug-only id for the one-off test notification fired from the debug screen.
/// Kept well clear of the (weekday, hour, minute) range used by [_notificationId]
/// so it never collides with a real scheduled reminder.
const int _testNotificationId = 0x7FFFFFF0;

/// Debug helper: schedules a single local notification [delay] from now, using
/// the same `'pray'` payload as real reminders. Lets you exercise the
/// notification-tap → Pray deep-link flow on demand — background or kill the app
/// during the delay to test warm- vs cold-start routing. Requests notification
/// permission first; returns false if it isn't granted.
Future<bool> scheduleTestReminder({
  Duration delay = const Duration(seconds: 10),
}) async {
  if (!_initialized) await initRemindersNotifications();
  final granted = await ensureNotificationPermission();
  if (!granted) return false;

  final canExact = await exactAlarmsAuthorized();
  final scheduleMode = canExact
      ? AndroidScheduleMode.exactAllowWhileIdle
      : AndroidScheduleMode.inexactAllowWhileIdle;

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
  );

  await _plugin.zonedSchedule(
    id: _testNotificationId,
    title: l.reminderNotificationTitle,
    body: l.reminderNotificationBody,
    scheduledDate: tz.TZDateTime.now(tz.local).add(delay),
    notificationDetails: NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    ),
    androidScheduleMode: scheduleMode,
    payload: 'pray',
  );
  return true;
}

/// Maps a (weekday, hour, minute) fire-time to a stable notification id.
/// Reminders that share a fire time share an id, so only one notification is
/// ever scheduled per distinct time — no duplicate alerts.
/// Bit layout (all positive, well under 32 bits): hour<<9 | minute<<3 | weekday.
int _notificationId(int weekday, int hour, int minute) =>
    (hour << 9) | (minute << 3) | (weekday & 0x7);

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

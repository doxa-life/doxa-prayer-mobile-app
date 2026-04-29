import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_localizations.dart';
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

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // Top-level handler required by flutter_local_notifications. The app may not
  // be alive yet; routing is handled by the foreground listener once the app
  // is up. We seed the payload notifier so the foreground side picks it up.
  reminderTapPayload.value = response.payload;
}

void _onTap(NotificationResponse response) {
  reminderTapPayload.value = response.payload;
}

Future<void> initRemindersNotifications() async {
  if (_initialized) return;
  tz.initializeTimeZones();
  // tz.initializeTimeZones() leaves tz.local set to UTC; set it to the
  // device's actual zone so scheduled times match what the user picked.
  try {
    final zoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zoneName));
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
    const InitializationSettings(android: androidInit, iOS: iosInit),
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
    return granted ?? false;
  }

  return true;
}

/// Schedules a weekly-repeating notification per selected weekday.
Future<void> scheduleReminder(Reminder r) async {
  if (!_initialized) await initRemindersNotifications();
  if (!r.enabled || r.weekdays.isEmpty) return;

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

  for (final weekday in r.weekdays) {
    final id = _notificationId(r.id, weekday);
    final fireAt = _nextInstanceOf(weekday, r.hour, r.minute);
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        fireAt,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: 'pray',
      );
    } catch (e) {
      debugPrint('reminders_notifications: schedule failed for $id: $e');
    }
  }
}

Future<void> cancelReminder(Reminder r) async {
  if (!_initialized) return;
  // Cancel every weekday slot we might have scheduled, regardless of the
  // reminder's current weekdays — handles reminders whose weekdays changed.
  for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
    await _plugin.cancel(_notificationId(r.id, weekday));
  }
}

Future<void> rescheduleAllReminders(List<Reminder> all) async {
  if (!_initialized) await initRemindersNotifications();
  await _plugin.cancelAll();
  for (final r in all) {
    if (r.enabled) await scheduleReminder(r);
  }
}

/// Maps (reminderId, weekday) to a stable 32-bit notification id.
/// Bottom 3 bits hold the weekday (1–7); upper bits come from the id hash.
/// Distinct (id, weekday) pairs never collide; cross-reminder collisions are
/// rare enough to be acceptable.
int _notificationId(String reminderId, int weekday) {
  final hash = reminderId.hashCode & 0x0FFFFFF8;
  return hash | (weekday & 0x7);
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

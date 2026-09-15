import 'package:doxa_prayer_mobile_app/services/reminder_schedule.dart';
import 'package:doxa_prayer_mobile_app/services/reminders_controller.dart';
import 'package:flutter_test/flutter_test.dart';

Reminder _r({
  required String id,
  required String slug,
  int hour = 8,
  int minute = 0,
  List<int> weekdays = const [1, 2, 3, 4, 5, 6, 7],
  bool enabled = true,
}) => Reminder(
  id: id,
  slug: slug,
  hour: hour,
  minute: minute,
  weekdays: weekdays,
  enabled: enabled,
);

void main() {
  tearDown(() => remindersController.value = null);

  test('a group with no reminders reports the daily 8am fallback', () {
    remindersController.value = const Reminders(list: []);
    final s = scheduleForGroup('kurds');
    expect(s.time, '08:00');
    expect(s.frequency, 'daily');
  });

  test('another group\'s reminders do not leak into this one', () {
    remindersController.value = Reminders(
      list: [_r(id: 'a', slug: 'fulani', hour: 6, minute: 15)],
    );
    // Fulani's 6:15 must not become the Kurds' schedule.
    expect(scheduleForGroup('kurds').time, '08:00');
    expect(scheduleForGroup('fulani').time, '06:15');
  });

  test('the earliest enabled reminder supplies the time', () {
    remindersController.value = Reminders(
      list: [
        _r(id: 'a', slug: 'kurds', hour: 21, minute: 30),
        _r(id: 'b', slug: 'kurds', hour: 7, minute: 0),
      ],
    );
    expect(scheduleForGroup('kurds').time, '07:00');
  });

  test('weekdays are the union across the group\'s enabled reminders', () {
    remindersController.value = Reminders(
      list: [
        _r(id: 'a', slug: 'kurds', hour: 7, weekdays: const [1, 2]),
        _r(id: 'b', slug: 'kurds', hour: 9, weekdays: const [2, 3]),
      ],
    );
    expect(scheduleForGroup('kurds').weekdays, [1, 2, 3]);
    expect(scheduleForGroup('kurds').frequency, 'weekly');
  });

  test('a disabled reminder still supplies a usable schedule', () {
    remindersController.value = Reminders(
      list: [
        _r(
          id: 'a',
          slug: 'kurds',
          hour: 6,
          minute: 45,
          weekdays: const [3],
          enabled: false,
        ),
      ],
    );
    final s = scheduleForGroup('kurds');
    expect(s.time, '06:45');
    expect(s.weekdays, [3]);
  });

  test('weekdays are re-encoded to the backend\'s Sun=0..Sat=6', () {
    remindersController.value = Reminders(
      list: [
        _r(id: 'a', slug: 'kurds', weekdays: const [6, 7]),
      ],
    );
    // Saturday stays 6; Sunday folds from 7 to 0.
    expect(scheduleForGroup('kurds').encodedWeekdays, [0, 6]);
  });
}

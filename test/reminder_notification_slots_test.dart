import 'package:doxa_prayer_mobile_app/services/reminders_controller.dart';
import 'package:doxa_prayer_mobile_app/services/reminders_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

Reminder _reminder({
  required String id,
  required String slug,
  int hour = 8,
  int minute = 0,
  List<int> weekdays = const [1],
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
  group('reminder notification slots', () {
    test(
      'two reminders for the same group at the same time share one slot',
      () {
        final slots = reminderNotificationSlots([
          _reminder(id: 'a', slug: 'kurds'),
          _reminder(id: 'b', slug: 'kurds'),
        ]);
        expect(slots, hasLength(1));
      },
    );

    test('two groups at the same time each get their own slot', () {
      final slots = reminderNotificationSlots([
        _reminder(id: 'a', slug: 'kurds'),
        _reminder(id: 'b', slug: 'fulani'),
      ]);
      expect(slots, hasLength(2));
      expect(
        slots.values.map((s) => s.slug),
        containsAll(<String>['kurds', 'fulani']),
      );
    });

    test('one slot per weekday', () {
      final slots = reminderNotificationSlots([
        _reminder(id: 'a', slug: 'kurds', weekdays: const [1, 2, 3]),
      ]);
      expect(slots, hasLength(3));
      expect(slots.values.map((s) => s.weekday), containsAll(<int>[1, 2, 3]));
    });

    test('disabled reminders are not scheduled', () {
      final slots = reminderNotificationSlots([
        _reminder(id: 'a', slug: 'kurds', enabled: false),
      ]);
      expect(slots, isEmpty);
    });

    test('ids stay inside the 32-bit range the platforms accept', () {
      final slots = reminderNotificationSlots([
        for (var i = 0; i < 50; i++)
          _reminder(
            id: 'r$i',
            slug: 'people-group-with-a-fairly-long-slug-$i',
            hour: 23,
            minute: 59,
            weekdays: const [7],
          ),
      ]);
      for (final id in slots.keys) {
        expect(id, greaterThanOrEqualTo(0));
        expect(id, lessThan(1 << 31));
      }
    });

    test('the same reminder always hashes to the same id', () {
      final first = reminderNotificationSlots([
        _reminder(id: 'a', slug: 'kurds'),
      ]).keys.single;
      final second = reminderNotificationSlots([
        _reminder(id: 'a', slug: 'kurds'),
      ]).keys.single;
      expect(first, second);
    });
  });
}

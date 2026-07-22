import 'package:doxa_prayer_mobile_app/screens/reminders_screen.dart';
import 'package:doxa_prayer_mobile_app/services/reminders_controller.dart';
import 'package:doxa_prayer_mobile_app/services/reminders_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_at_scale.dart';

const _reminder = Reminder(
  id: 'r1',
  hour: 7,
  minute: 30,
  weekdays: [1, 2, 3, 4, 5],
  enabled: true,
);

void main() {
  setUp(() {
    notificationsBlocked.value = true;
    remindersController.value = const Reminders(list: [_reminder]);
  });

  tearDown(() {
    notificationsBlocked.value = false;
    remindersController.value = null;
  });

  testWidgets(
    'banner and reminders stay reachable at 3x font scale',
    (tester) async {
      await pumpAtScale(tester, const RemindersScreen(), scale: 3.0);

      // No RenderFlex overflow at large font scales.
      expect(tester.takeException(), isNull);

      // The blocked-notifications banner scrolls with the content and the
      // reminder card below it can be scrolled into view.
      expect(find.byIcon(Icons.notifications_off), findsOneWidget);
      // textContaining: intl separates time and day period with a narrow
      // no-break space, so an exact '7:30 AM' match would be brittle.
      final card = find.textContaining('7:30');
      await tester.scrollUntilVisible(card, 100);
      expect(card, findsOneWidget);
    },
  );

  testWidgets('empty state shows no overflow at 3x font scale', (
    tester,
  ) async {
    remindersController.value = const Reminders(list: []);

    await pumpAtScale(tester, const RemindersScreen(), scale: 3.0);

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.notifications_off), findsOneWidget);
  });
}

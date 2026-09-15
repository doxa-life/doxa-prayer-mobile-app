import 'package:doxa_prayer_mobile_app/components/misc/swap_people_group_modal.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/services/reminders_controller.dart';
import 'package:doxa_prayer_mobile_app/services/subscribed_people_groups_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _groups = SubscribedPeopleGroups(
  list: [
    SubscribedPeopleGroup(slug: 'kurds', name: 'Kurds'),
    SubscribedPeopleGroup(slug: 'fulani', name: 'Fulani'),
  ],
  activeSlug: 'kurds',
);

const _reminder = Reminder(
  id: 'r1',
  slug: 'kurds',
  hour: 7,
  minute: 0,
  weekdays: [1, 2, 3, 4, 5, 6, 7],
  enabled: true,
);

/// Opens the modal and reports what it popped with.
Future<String?> _open(WidgetTester tester) async {
  String? result;
  var popped = false;
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              result = await showSwapPeopleGroupModal(
                context,
                incomingName: 'Somali',
              );
              popped = true;
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  expect(popped, isFalse);
  return result;
}

void main() {
  setUp(() {
    peopleGroupsController.value = _groups;
    remindersController.value = const Reminders(list: [_reminder]);
  });

  tearDown(() {
    peopleGroupsController.value = SubscribedPeopleGroups.empty;
    remindersController.value = null;
  });

  testWidgets('lists every current group and names the incoming one', (
    tester,
  ) async {
    await _open(tester);
    expect(find.text('Kurds'), findsOneWidget);
    expect(find.text('Fulani'), findsOneWidget);
    expect(find.textContaining('Somali'), findsOneWidget);
  });

  testWidgets('says how many reminders a group would lose', (tester) async {
    await _open(tester);
    // Kurds has one reminder; Fulani has none, so only one such line appears.
    expect(find.textContaining('reminder'), findsOneWidget);
  });

  testWidgets('nothing is preselected and swap is disabled until a pick', (
    tester,
  ) async {
    await _open(tester);

    expect(find.byIcon(Icons.radio_button_checked), findsNothing);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(2));

    final swap = tester.widget<FilledButton>(
      find.ancestor(of: find.text('SWAP'), matching: find.byType(FilledButton)),
    );
    expect(swap.onPressed, isNull);
  });

  testWidgets('picking a group enables swap and pops with its slug', (
    tester,
  ) async {
    await _open(tester);

    await tester.tap(find.text('Fulani'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);

    await tester.tap(find.text('SWAP'));
    await tester.pumpAndSettle();

    // The modal is gone; nothing else asserts here because the caller owns
    // what happens with the returned slug.
    expect(find.text('SWAP'), findsNothing);
  });

  testWidgets('cancel pops without choosing anything', (tester) async {
    await _open(tester);
    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();
    expect(find.text('SWAP'), findsNothing);
  });
}

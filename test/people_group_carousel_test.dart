import 'package:doxa_prayer_mobile_app/components/cards/add_people_group_card.dart';
import 'package:doxa_prayer_mobile_app/components/cards/people_group_card.dart';
import 'package:doxa_prayer_mobile_app/components/cards/people_group_carousel.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/services/prayer_history_service.dart';
import 'package:doxa_prayer_mobile_app/services/subscribed_people_groups_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

List<SubscribedPeopleGroup> _groups(int n) => [
  for (var i = 0; i < n; i++)
    SubscribedPeopleGroup(slug: 'group-$i', name: 'Group $i'),
];

Future<void> _pump(
  WidgetTester tester,
  List<SubscribedPeopleGroup> groups, {
  String? activeSlug,
  ValueChanged<SubscribedPeopleGroup>? onPray,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Wrapped in a vertical scroll view because that is what the home
      // screen does — it leaves the carousel's height unbounded, which a
      // bounded Scaffold body would hide.
      home: Scaffold(
        body: SingleChildScrollView(
          child: PeopleGroupCarousel(
            groups: groups,
            activeSlug: activeSlug,
            onPray: onPray ?? (_) {},
            onDetails: (_) {},
            onShare: (_) {},
            onShowQr: (_) {},
            onAdd: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => prayedTodayController.value = <String>{});

  testWidgets('renders one card per group plus the add card', (tester) async {
    await _pump(tester, _groups(3));
    expect(find.byType(PeopleGroupCard), findsNWidgets(3));
    expect(find.byType(AddPeopleGroupCard), findsOneWidget);
  });

  testWidgets('the add card disappears at the limit', (tester) async {
    await _pump(tester, _groups(kMaxPeopleGroups));
    expect(find.byType(PeopleGroupCard), findsNWidgets(kMaxPeopleGroups));
    expect(find.byType(AddPeopleGroupCard), findsNothing);
  });

  testWidgets('opens scrolled to the active group', (tester) async {
    await _pump(tester, _groups(4), activeSlug: 'group-2');

    // The carousel's own (horizontal) scrollable, not the page's vertical one.
    final scrollable = tester.widget<Scrollable>(
      find.descendant(
        of: find.byType(PeopleGroupCarousel),
        matching: find.byType(Scrollable),
      ),
    );
    // The whole point of the scroll: the active card is not the one at rest
    // when it is not first in the list.
    expect(scrollable.controller!.offset, greaterThan(0));
  });

  testWidgets('stays at rest when the active group is already first', (
    tester,
  ) async {
    await _pump(tester, _groups(4), activeSlug: 'group-0');
    // The carousel's own (horizontal) scrollable, not the page's vertical one.
    final scrollable = tester.widget<Scrollable>(
      find.descendant(
        of: find.byType(PeopleGroupCarousel),
        matching: find.byType(Scrollable),
      ),
    );
    expect(scrollable.controller!.offset, 0);
  });

  testWidgets('scrolls horizontally without overflowing', (tester) async {
    await _pump(tester, _groups(kMaxPeopleGroups));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a group prayed for today shows the pill', (tester) async {
    prayedTodayController.value = {'group-1'};
    await _pump(tester, _groups(2));

    final cards = tester
        .widgetList<PeopleGroupCard>(find.byType(PeopleGroupCard))
        .toList();
    expect(cards[0].prayedToday, isFalse);
    expect(cards[1].prayedToday, isTrue);
  });

  testWidgets('praying from a card reports which group it was', (tester) async {
    String? prayedFor;
    await _pump(tester, _groups(2), onPray: (g) => prayedFor = g.slug);

    await tester.tap(find.text('PRAY').first);
    await tester.pumpAndSettle();
    expect(prayedFor, 'group-0');
  });
}

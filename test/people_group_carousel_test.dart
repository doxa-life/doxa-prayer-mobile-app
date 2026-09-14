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
            onMap: (_) {},
            onAdd: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The carousel's own (horizontal) scrollable, not the page's vertical one.
Finder _carouselScrollable() => find.descendant(
  of: find.byType(PeopleGroupCarousel),
  matching: find.byType(Scrollable),
);

double _controllerOffset(WidgetTester tester) =>
    tester.widget<Scrollable>(_carouselScrollable()).controller!.offset;

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

  testWidgets('centres the active group', (tester) async {
    await _pump(tester, _groups(5), activeSlug: 'group-2');

    final card = tester.getRect(find.byType(PeopleGroupCard).at(2));
    final viewport = tester.getRect(_carouselScrollable());
    expect(card.center.dx, moreOrLessEquals(viewport.center.dx, epsilon: 1));
  });

  testWidgets('the first group rests fully visible, not half off the left', (
    tester,
  ) async {
    await _pump(tester, _groups(5), activeSlug: 'group-0');

    expect(_controllerOffset(tester), 0);
    final card = tester.getRect(find.byType(PeopleGroupCard).first);
    final viewport = tester.getRect(_carouselScrollable());
    expect(card.left, greaterThanOrEqualTo(viewport.left));
    expect(card.right, lessThanOrEqualTo(viewport.right));
  });

  testWidgets('the last group rests fully visible at the far end', (
    tester,
  ) async {
    // At the cap there is no "add another" card after the last group, so this
    // is the case that has to clamp rather than centre.
    await _pump(
      tester,
      _groups(kMaxPeopleGroups),
      activeSlug: 'group-${kMaxPeopleGroups - 1}',
    );

    final position = tester
        .state<ScrollableState>(_carouselScrollable())
        .position;
    expect(_controllerOffset(tester), position.maxScrollExtent);

    final card = tester.getRect(find.byType(PeopleGroupCard).last);
    final viewport = tester.getRect(_carouselScrollable());
    expect(card.right, lessThanOrEqualTo(viewport.right + 0.01));
    expect(card.left, greaterThanOrEqualTo(viewport.left));
  });

  testWidgets('the add card counts as the last card, so the final group '
      'can still be centred', (tester) async {
    // Four groups plus the add card: group-3 has content after it, so unlike
    // the capped case above it centres instead of clamping.
    await _pump(tester, _groups(4), activeSlug: 'group-3');

    final card = tester.getRect(find.byType(PeopleGroupCard).at(3));
    final viewport = tester.getRect(_carouselScrollable());
    expect(card.center.dx, moreOrLessEquals(viewport.center.dx, epsilon: 1));
  });

  testWidgets('follows the active group when it changes', (tester) async {
    await _pump(tester, _groups(5), activeSlug: 'group-0');
    expect(_controllerOffset(tester), 0);

    // A switch made from the Pray tab arrives as a changed activeSlug.
    await _pump(tester, _groups(5), activeSlug: 'group-4');
    await tester.pumpAndSettle();

    expect(_controllerOffset(tester), greaterThan(0));
    final card = tester.getRect(find.byType(PeopleGroupCard).last);
    final viewport = tester.getRect(_carouselScrollable());
    expect(card.right, lessThanOrEqualTo(viewport.right + 0.01));
  });

  testWidgets('cards are inset so their shadows are not clipped away', (
    tester,
  ) async {
    await _pump(tester, _groups(3), activeSlug: 'group-0');

    final viewport = tester.getRect(_carouselScrollable());
    final card = tester.getRect(find.byType(PeopleGroupCard).first);
    // Room on the left of the first card, and above/below every card, for the
    // elevation shadow to fall inside the scroll view's clip.
    expect(card.left - viewport.left, greaterThan(0));
    expect(card.top - viewport.top, greaterThan(0));
    expect(viewport.bottom - card.bottom, greaterThan(0));
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

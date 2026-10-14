import 'package:doxa_prayer_mobile_app/components/inputs/filter_section.dart';
import 'package:doxa_prayer_mobile_app/components/widgets/people_groups_list.dart';
import 'package:doxa_prayer_mobile_app/models/people_group.dart';
import 'package:doxa_prayer_mobile_app/services/people_groups_service.dart';
import 'package:doxa_prayer_mobile_app/services/response_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_at_scale.dart';

PeopleGroup _group(int i) => PeopleGroup(
  name: 'Group $i',
  slug: 'group-$i',
  imageUrl: null,
  countryLabel: 'Malaysia',
  countryCode: 'MYS',
  religionLabel: i.isEven ? 'Islam - Sunni' : 'Hinduism',
  religionAlternates: i.isEven ? const ['Muslim'] : const [],
  primaryLanguageLabel: 'Malay',
  population: 1000 * (i + 1),
  engagementStatusValue: 'unengaged',
  regionValue: 'asia',
  peoplePraying: 0,
  peopleCommitted: 0,
);

void main() {
  // The background refresh reads the API host from .env; it then fails
  // offline, which is fine — the seeded cache stays on screen.
  setUpAll(() => dotenv.testLoad());
  setUp(clearMemoryCache);
  tearDown(clearMemoryCache);

  Future<void> pumpList(WidgetTester tester, {int count = 30}) async {
    seedMemoryCache(peopleGroupListCacheKey('en'), [
      for (var i = 0; i < count; i++) _group(i),
    ]);
    await pumpAtScale(tester, const PeopleGroupsList(), scale: 1.0);
    await tester.pump();
  }

  testWidgets('the filter button opens and closes the panel', (tester) async {
    await pumpList(tester);
    expect(find.byType(FilterSection), findsNothing);

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    expect(find.byType(FilterSection), findsWidgets);

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    expect(find.byType(FilterSection), findsNothing);
  });

  testWidgets('the panel opens in view after scrolling down', (tester) async {
    await pumpList(tester, count: 60);
    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    expect(find.byType(FilterSection).hitTestable(), findsWidgets);
  });

  testWidgets('results run fewest intercessors first, then A–Z', (
    tester,
  ) async {
    PeopleGroup group(String name, int committed, int resources) => PeopleGroup(
      name: name,
      slug: name.toLowerCase(),
      imageUrl: null,
      countryLabel: 'Malaysia',
      religionLabel: 'Hinduism',
      peoplePraying: 0,
      peopleCommitted: committed,
      resourcesAvailable: resources,
    );
    // Resource counts deliberately disagree with the names: the list used to
    // break ties on them, which nobody can see, so the names restarted at A
    // part-way through a run of equal counts.
    seedMemoryCache(peopleGroupListCacheKey('en'), [
      group('Delta', 0, 0),
      group('Bravo', 0, 6),
      group('Alpha', 0, 3),
      group('Echo', 2, 0),
      group('Charlie', 1, 5),
    ]);
    // Tall enough that every card is built.
    await pumpAtScale(
      tester,
      const PeopleGroupsList(),
      scale: 1.0,
      viewport: const Size(360, 2400),
    );
    await tester.pumpAndSettle();

    final order = ['Alpha', 'Bravo', 'Delta', 'Charlie', 'Echo'];
    final tops = [for (final n in order) tester.getTopLeft(find.text(n)).dy];
    expect(tops, orderedEquals([...tops]..sort()));
  });

  testWidgets('cards scrolled into view are shown at once', (tester) async {
    await pumpList(tester, count: 60);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pump(); // One frame: no time for any entrance to play.

    final card = find.byKey(const ValueKey('group-20'));
    expect(card.hitTestable(), findsOneWidget);
    final fade = tester.widget<FadeTransition>(
      find.descendant(of: card, matching: find.byType(FadeTransition)).first,
    );
    expect(fade.opacity.value, 1);
  });
}

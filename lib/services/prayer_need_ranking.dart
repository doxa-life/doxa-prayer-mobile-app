import 'dart:math';

import '../models/people_group.dart';

/// Orders [a] before [b] when it needs prayer more — onboarding's "pick a
/// group for me" takes the first group in this order:
///
///  1. fewest people committed to praying (the count the list and profile
///     show),
///  2. then fewest outreach resources available in its language.
///
/// An unknown resource count sorts after known ones — safer than assuming
/// it's low. Groups level on both are a tie (0): [rankByPrayerNeed] shuffles
/// them, so "pick a group for me" doesn't hand everyone the same group.
int compareByPrayerNeed(PeopleGroup a, PeopleGroup b) {
  final praying = a.peopleCommitted.compareTo(b.peopleCommitted);
  if (praying != 0) return praying;
  return _compareKnownFirst(a.resourcesAvailable, b.resourcesAvailable);
}

/// Every group in [groups], neediest first (see [compareByPrayerNeed]), with
/// each run of tied groups in random order. Always ranks the whole set it's
/// given: counts change as people start and stop praying, so no group is
/// ever ruled out ahead of time. Pass [random] for a repeatable order.
List<PeopleGroup> rankByPrayerNeed(
  Iterable<PeopleGroup> groups, {
  Random? random,
}) {
  final rng = random ?? Random();
  final ranked = [...groups]..sort(compareByPrayerNeed);
  var start = 0;
  for (var i = 1; i <= ranked.length; i++) {
    final runEnds =
        i == ranked.length ||
        compareByPrayerNeed(ranked[start], ranked[i]) != 0;
    if (!runEnds) continue;
    if (i - start > 1) {
      final run = ranked.sublist(start, i)..shuffle(rng);
      ranked.setRange(start, i, run);
    }
    start = i;
  }
  return ranked;
}

int _compareKnownFirst(int? a, int? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return a.compareTo(b);
}

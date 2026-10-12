import 'dart:math';

import 'package:doxa_prayer_mobile_app/models/people_group.dart';
import 'package:doxa_prayer_mobile_app/services/prayer_need_ranking.dart';
import 'package:flutter_test/flutter_test.dart';

PeopleGroup _g(
  String slug, {
  int praying = 0,
  int? resources,
  int? population,
}) => PeopleGroup(
  name: slug,
  slug: slug,
  imageUrl: null,
  countryLabel: null,
  religionLabel: null,
  peoplePraying: 0,
  peopleCommitted: praying,
  resourcesAvailable: resources,
  population: population,
);

List<String> _order(List<PeopleGroup> groups) =>
    rankByPrayerNeed(groups).map((g) => g.slug).toList();

void main() {
  test('fewest people praying comes first, whatever else', () {
    expect(
      _order([
        _g('praying-2', praying: 2, resources: 0, population: 10),
        _g('praying-0', praying: 0, resources: 6, population: 9000000),
      ]),
      ['praying-0', 'praying-2'],
    );
  });

  test('then fewest resources, ahead of population', () {
    expect(
      _order([
        _g('res-5-tiny', resources: 5, population: 10),
        _g('res-1-huge', resources: 1, population: 9000000),
      ]),
      ['res-1-huge', 'res-5-tiny'],
    );
  });

  test('unknown resources sort after known ones', () {
    expect(_order([_g('unknown-res'), _g('known-res', resources: 6)]), [
      'known-res',
      'unknown-res',
    ]);
  });

  test('tied groups come out in random order, still ahead of the rest', () {
    final groups = [
      _g('more-praying', praying: 3),
      for (var i = 0; i < 8; i++) _g('tied-$i', resources: 0, population: i),
    ];
    final firsts = <String>{};
    for (var seed = 0; seed < 20; seed++) {
      final order = rankByPrayerNeed(
        groups,
        random: Random(seed),
      ).map((g) => g.slug).toList();
      expect(order.last, 'more-praying');
      expect(order.take(8).toSet(), {for (var i = 0; i < 8; i++) 'tied-$i'});
      firsts.add(order.first);
    }
    // Population no longer breaks the tie: different groups come first.
    expect(firsts.length, greaterThan(1));
  });

  group('resourcesAvailable parsing', () {
    Map<String, dynamic> json(Map<String, dynamic> extra) => {
      'name': 'X',
      'slug': 'x',
      ...extra,
    };

    test('uses the API total (sent as a string) when present', () {
      final g = PeopleGroup.fromJson(
        json({
          'imb_total_resources_available': '4',
          'imb_bible_available': false,
        }),
      );
      expect(g.resourcesAvailable, 4);
    });

    test('counts the true flags when the total is null', () {
      final g = PeopleGroup.fromJson(
        json({
          'imb_total_resources_available': null,
          'imb_bible_available': true,
          'imb_jesus_film_available': true,
          'imb_radio_broadcast_available': false,
          'imb_gospel_recordings_available': false,
          'imb_audio_scripture_available': true,
          'imb_bible_stories_available': false,
        }),
      );
      expect(g.resourcesAvailable, 3);
    });

    test('is null when neither the total nor any flag is present', () {
      expect(PeopleGroup.fromJson(json({})).resourcesAvailable, isNull);
    });
  });
}

import 'dart:developer' as developer;

import '../models/prayer_content.dart';
import 'image_cache_manager.dart';
import 'locale_controller.dart';
import 'people_groups_service.dart';
import 'prayer_content_service.dart';
import 'subscribed_people_groups_controller.dart';

/// Prepares the caches at launch so the first tap on a tab has nothing to wait
/// for.
///
/// In order:
///  * The people-group list and the user's own groups' profiles are *warmed*
///    first — read from disk into memory if already cached — so a relaunch
///    paints them without a skeleton.
///  * Today's prayer content is *prefetched* — downloaded if missing, along
///    with the photos it renders — because the Pray tab is the point of the
///    app. Every subscribed group is fetched, one after another rather than
///    all at once, so five subscriptions trickle over a poor connection
///    instead of bursting.
///  * Then the profiles of the user's own groups, so opening one from the
///    home screen is instant too.
///
/// The browse list itself is fetched by the Search tab, which is built at
/// launch (see `SwipeableBranchContainer`), so it is not repeated here; the
/// two would share one request anyway.
///
/// Fire-and-forget, and silent on failure: nothing here may block or break app
/// start, and every screen still fetches for itself.
Future<void> warmCachesOnLaunch() async {
  final lang = localeController.value.languageCode;
  final groups = peopleGroupsController.value;
  final slugs = [for (final g in groups.list) g.slug];
  await Future.wait([
    _warmPeopleGroups(lang: lang, slugs: slugs),
    _prefetchTodaysPrayerContent(lang: lang, slugs: slugs),
  ]);
  await _prefetchProfiles(lang: lang, slugs: slugs);
}

/// The user's own groups' profiles, fetched if not already cached.
Future<void> _prefetchProfiles({
  required String lang,
  required List<String> slugs,
}) async {
  for (final slug in slugs) {
    if (slug.isEmpty) continue;
    try {
      await fetchPeopleGroupDetail(slug, lang: lang);
    } catch (e) {
      developer.log(
        'profile prefetch failed for $slug',
        name: 'cache_warmup',
        error: e,
      );
    }
  }
}

Future<void> _warmPeopleGroups({
  required String lang,
  required List<String> slugs,
}) async {
  try {
    await warmPeopleGroupCaches(lang: lang, subscribedSlugs: slugs);
  } catch (e) {
    developer.log(
      'people group warm-up failed',
      name: 'cache_warmup',
      error: e,
    );
  }
}

Future<void> _prefetchTodaysPrayerContent({
  required String lang,
  required List<String> slugs,
}) async {
  // No subscriptions yet — the user is heading into the wizard, and there is no
  // way to know which group they'll pick.
  final date = DateTime.now();
  for (final slug in slugs) {
    try {
      final content = await fetchPrayerContent(
        slug: slug,
        date: date,
        language: lang,
      );
      await _warmImages(content);
    } catch (e) {
      developer.log(
        'prayer content prefetch failed for $slug',
        name: 'cache_warmup',
        error: e,
      );
    }
  }
}

/// Loads one prayer — the content and the photos it renders — ahead of the
/// user reaching it, so it paints with no skeleton when they do: the
/// neighbouring groups' prayers on the Pray tab, the group a swipe is heading
/// to, the day before the one on show.
///
/// Costs nothing when the prayer is already cached, and shares the request
/// when the screen asks for the same prayer at the same moment. Silent on
/// failure; the screen fetches for itself.
Future<void> prefetchPrayer({
  required String slug,
  required DateTime date,
  required String language,
}) async {
  try {
    final content = await fetchPrayerContent(
      slug: slug,
      date: date,
      language: language,
    );
    await _warmImages(content);
  } catch (e) {
    developer.log(
      'prayer prefetch failed for $slug',
      name: 'cache_warmup',
      error: e,
    );
  }
}

/// Pulls down the photos the prayer page will render — the hero image plus the
/// one on each people-group block — so the first paint has them locally.
Future<void> _warmImages(PrayerContentResponse content) async {
  final urls = <String>{
    ?content.peopleGroup.imageUrl,
    for (final block in content.content) ?block.peopleGroupData?.imageUrl,
  }..removeWhere((url) => url.isEmpty);
  await Future.wait(urls.map(AppImageCacheManager.warm));
}

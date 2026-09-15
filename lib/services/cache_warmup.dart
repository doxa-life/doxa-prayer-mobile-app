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
/// Two different jobs:
///  * The people-group list and the user's own group are only *warmed* — read
///    from disk into memory if already cached, never downloaded. The list is
///    ~850 KB, so fetching it at launch would spend a user's data on a tab they
///    may not open; but decoding it up front is what stops the browse tab from
///    flashing a skeleton, which is the slow part on a relaunch.
///  * Today's prayer content is genuinely *prefetched* — downloaded if missing,
///    along with the photos it renders — because the Pray tab is the point of
///    the app and each one is a small request. Every subscribed group is
///    fetched, one after another rather than all at once, so five
///    subscriptions trickle over a poor connection instead of bursting.
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

/// Pulls down the photos the prayer page will render — the hero image plus the
/// one on each people-group block — so the first paint has them locally.
Future<void> _warmImages(PrayerContentResponse content) async {
  final urls = <String>{
    ?content.peopleGroup.imageUrl,
    for (final block in content.content) ?block.peopleGroupData?.imageUrl,
  }..removeWhere((url) => url.isEmpty);
  await Future.wait(urls.map(AppImageCacheManager.warm));
}

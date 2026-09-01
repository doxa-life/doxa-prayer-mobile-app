/// How long each kind of fetched data stays usable without going back to the
/// network. All four caches are declared here so the policy can be read — and
/// changed — in one place.
///
/// Every entry is a *soft* expiry: past it the app refetches, but a failed
/// refetch still falls back to the expired copy (see `response_cache.dart`), so
/// an offline user keeps seeing the last thing they loaded.
class CachePolicy {
  CachePolicy._();

  /// People-group photos, held on disk by `image_cache_manager.dart`.
  static const Duration images = Duration(days: 30);

  /// A single day's prayer content for one people group and language. Keyed by
  /// date, so each day is cached separately and past days never change.
  static const Duration prayerContent = Duration(days: 30);

  /// The UUPG (unreached people group) browse list.
  static const Duration peopleGroupList = Duration(days: 7);

  /// One people group's detail page.
  static const Duration peopleGroupDetail = Duration(days: 7);

  /// How long a people-group payload may go without a background refresh.
  ///
  /// The list and detail responses carry the people-praying and
  /// people-committed counts, which move as others pray and shouldn't sit
  /// frozen for the whole 7 days. Past this the cached copy is still shown
  /// immediately — the refresh happens behind it and the counts update in
  /// place, so the user never waits for it.
  static const Duration peopleGroupCounts = Duration(hours: 1);

  /// The longest of the response TTLs — how far back the startup sweep in
  /// `response_cache.dart` keeps files before deleting them.
  static const Duration maxResponseAge = prayerContent;
}

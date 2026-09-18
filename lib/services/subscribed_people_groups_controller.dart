import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The most people groups one person may pray for at once. The cap is only
/// user-visible at the point of adding a sixth — see the swap flow in
/// `people_group_subscription_flow.dart`.
const int kMaxPeopleGroups = 5;

@immutable
class SubscribedPeopleGroup {
  const SubscribedPeopleGroup({
    required this.slug,
    required this.name,
    this.imageUrl,
    this.subscriptionId,
  });

  final String slug;
  final String name;
  final String? imageUrl;

  /// The server's `campaign_subscriptions.id` for this group, returned by
  /// anon-signup. Null until that call lands; without it we cannot unsubscribe
  /// precisely and would have to fall back to leaving the row alone.
  final int? subscriptionId;

  SubscribedPeopleGroup copyWith({
    String? name,
    String? imageUrl,
    int? subscriptionId,
  }) => SubscribedPeopleGroup(
    slug: slug,
    name: name ?? this.name,
    imageUrl: imageUrl ?? this.imageUrl,
    subscriptionId: subscriptionId ?? this.subscriptionId,
  );

  Map<String, dynamic> toJson() => {
    'slug': slug,
    'name': name,
    if (imageUrl != null) 'imageUrl': imageUrl,
    if (subscriptionId != null) 'subscriptionId': subscriptionId,
  };

  factory SubscribedPeopleGroup.fromJson(Map<String, dynamic> json) =>
      SubscribedPeopleGroup(
        slug: json['slug'] as String,
        name: json['name'] as String,
        imageUrl: json['imageUrl'] as String?,
        subscriptionId: (json['subscriptionId'] as num?)?.toInt(),
      );
}

@immutable
class SubscribedPeopleGroups {
  const SubscribedPeopleGroups({required this.list, this.activeSlug});

  /// In the order they were added, oldest first — the order the home carousel
  /// renders, so a card never moves once it is on screen.
  final List<SubscribedPeopleGroup> list;

  /// The group the Pray tab opens on: the last one the user chose to pray for,
  /// by any route. Null falls back to the first subscription.
  final String? activeSlug;

  static const empty = SubscribedPeopleGroups(list: <SubscribedPeopleGroup>[]);

  bool get isEmpty => list.isEmpty;
  bool get isFull => list.length >= kMaxPeopleGroups;
  bool contains(String slug) => list.any((g) => g.slug == slug);

  SubscribedPeopleGroup? bySlug(String slug) {
    for (final g in list) {
      if (g.slug == slug) return g;
    }
    return null;
  }

  /// The active group, resolved: the entry matching [activeSlug] if it is still
  /// subscribed, otherwise the first, otherwise null. Resolving here (rather
  /// than keeping activeSlug always valid) means removing the active group
  /// needs no separate fix-up.
  SubscribedPeopleGroup? get active {
    if (list.isEmpty) return null;
    final slug = activeSlug;
    if (slug != null) {
      final match = bySlug(slug);
      if (match != null) return match;
    }
    return list.first;
  }
}

const _subscriptionsKey = 'people_group_subscriptions';
const _activeSlugKey = 'active_people_group_slug';

// The pre-multi-group keys, read once by the migration and then deleted.
const _legacySlugKey = 'selected_people_group_slug';
const _legacyNameKey = 'selected_people_group_name';
const _legacyImageUrlKey = 'selected_people_group_image_url';
const _legacySubscriptionIdKey = 'identity_subscription_id';

final ValueNotifier<SubscribedPeopleGroups> peopleGroupsController =
    ValueNotifier<SubscribedPeopleGroups>(SubscribedPeopleGroups.empty);

/// Shorthand for the resolved active group — the single most-read thing here.
SubscribedPeopleGroup? get activePeopleGroup =>
    peopleGroupsController.value.active;

Future<void> loadPeopleGroups() async {
  final prefs = SharedPreferencesAsync();
  final raw = await prefs.getString(_subscriptionsKey);
  if (raw == null) {
    await _migrateFromSingleSelection(prefs);
    return;
  }
  try {
    final json = jsonDecode(raw) as List<dynamic>;
    peopleGroupsController.value = SubscribedPeopleGroups(
      list: [
        for (final e in json)
          SubscribedPeopleGroup.fromJson(e as Map<String, dynamic>),
      ],
      activeSlug: await prefs.getString(_activeSlugKey),
    );
  } catch (e) {
    // A corrupt blob must not wedge startup — better to look unsubscribed than
    // to crash on every launch, and the user can re-add.
    developer.log(
      'failed to decode people group subscriptions',
      name: 'subscribed_people_groups_controller',
      error: e,
    );
    peopleGroupsController.value = SubscribedPeopleGroups.empty;
  }
}

/// One-time upgrade from the single-selection keys. The one group the user had
/// becomes their first subscription, carrying the subscription id that used to
/// live on the identity record. The legacy keys are removed so this never runs
/// twice; `identity_subscription_id` is left alone because the news-signup path
/// still writes it.
Future<void> _migrateFromSingleSelection(SharedPreferencesAsync prefs) async {
  final slug = await prefs.getString(_legacySlugKey);
  final name = await prefs.getString(_legacyNameKey);
  if (slug == null || slug.isEmpty || name == null) {
    peopleGroupsController.value = SubscribedPeopleGroups.empty;
    return;
  }
  final group = SubscribedPeopleGroup(
    slug: slug,
    name: name,
    imageUrl: await prefs.getString(_legacyImageUrlKey),
    subscriptionId: await prefs.getInt(_legacySubscriptionIdKey),
  );
  developer.log(
    'migrated single selection "$slug" to the subscription list',
    name: 'subscribed_people_groups_controller',
  );
  await _persist(SubscribedPeopleGroups(list: [group], activeSlug: slug));
  await prefs.remove(_legacySlugKey);
  await prefs.remove(_legacyNameKey);
  await prefs.remove(_legacyImageUrlKey);
}

Future<void> _persist(SubscribedPeopleGroups next) async {
  peopleGroupsController.value = next;
  final prefs = SharedPreferencesAsync();
  await prefs.setString(
    _subscriptionsKey,
    jsonEncode(next.list.map((g) => g.toJson()).toList()),
  );
  final slug = next.activeSlug;
  if (slug == null) {
    await prefs.remove(_activeSlugKey);
  } else {
    await prefs.setString(_activeSlugKey, slug);
  }
}

/// Adds [group] and makes it active. Returns false when it is already
/// subscribed or the cap is reached — callers at the cap should offer the swap
/// flow rather than treating this as an error.
Future<bool> addPeopleGroup(SubscribedPeopleGroup group) async {
  final current = peopleGroupsController.value;
  if (current.contains(group.slug) || current.isFull) return false;
  await _persist(
    SubscribedPeopleGroups(
      list: [...current.list, group],
      activeSlug: group.slug,
    ),
  );
  return true;
}

/// Removes the subscription. Reminders belonging to it are deleted by the
/// remove flow, not here — this file owns storage, not the cascade.
Future<void> removePeopleGroup(String slug) async {
  final current = peopleGroupsController.value;
  if (!current.contains(slug)) return;
  await _persist(
    SubscribedPeopleGroups(
      list: [
        for (final g in current.list)
          if (g.slug != slug) g,
      ],
      // Clearing the slug when the active group goes lets `active` fall back to
      // the first remaining subscription.
      activeSlug: current.activeSlug == slug ? null : current.activeSlug,
    ),
  );
}

Future<void> setActivePeopleGroup(String slug) async {
  final current = peopleGroupsController.value;
  if (current.activeSlug == slug || !current.contains(slug)) return;
  await _persist(SubscribedPeopleGroups(list: current.list, activeSlug: slug));
}

/// Records the server's subscription id for [slug] once anon-signup returns it.
Future<void> setPeopleGroupSubscriptionId(
  String slug,
  int subscriptionId,
) async {
  final current = peopleGroupsController.value;
  final existing = current.bySlug(slug);
  if (existing == null || existing.subscriptionId == subscriptionId) return;
  await _persist(
    SubscribedPeopleGroups(
      list: [
        for (final g in current.list)
          if (g.slug == slug) g.copyWith(subscriptionId: subscriptionId) else g,
      ],
      activeSlug: current.activeSlug,
    ),
  );
}

/// Wipes every subscription. Only the debug screen's reset uses this — the
/// user-facing path is [removePeopleGroup] one group at a time.
Future<void> clearPeopleGroups() async {
  peopleGroupsController.value = SubscribedPeopleGroups.empty;
  final prefs = SharedPreferencesAsync();
  await prefs.remove(_subscriptionsKey);
  await prefs.remove(_activeSlugKey);
}

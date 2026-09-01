import 'dart:convert';

import 'package:flutter/foundation.dart' show compute;

import '../models/people_group.dart';
import '../models/people_group_detail.dart';
import 'api_config.dart';
import 'cache_policy.dart';
import 'response_cache.dart';

const _listFields = 'name,slug,image_url,country_code,religion,people_praying';

/// Cache keys are exposed so a screen can peek the in-memory cache before its
/// first frame (see `CachedDataBuilder`); they must match what the fetch below
/// stores under.
String peopleGroupListCacheKey(String lang) => 'pg-list-$lang';

String peopleGroupDetailCacheKey(String slug, String lang) =>
    'pg-detail-$slug-$lang';

/// The response is ~850 KB for the full list, and `jsonDecode` on that blocks
/// long enough to drop frames — so parsing happens in a background isolate.
/// Only the decode is offloaded: building the 2,000-odd small model objects is
/// cheap, and doing it here keeps the isolate boundary to plain JSON.
Future<List<PeopleGroup>> _parseList(String body) async {
  final json = await compute(jsonDecode, body) as Map<String, dynamic>;
  final posts = json['posts'] as List<dynamic>;
  return posts
      .map((e) => PeopleGroup.fromJson(e as Map<String, dynamic>))
      .toList(growable: false);
}

/// The UUPG browse list in [lang], cached on disk for
/// [CachePolicy.peopleGroupList] and refreshed in the background once the
/// cached copy is older than [CachePolicy.peopleGroupCounts].
///
/// Pass [forceRefresh] for an explicit user retry.
Future<List<PeopleGroup>> fetchPeopleGroups({
  required String lang,
  bool forceRefresh = false,
}) {
  return getJsonCached(
    uri: ApiConfig.buildUri('/api/people-groups/list', {
      'lang': lang,
      'fields': _listFields,
    }),
    cacheKey: peopleGroupListCacheKey(lang),
    ttl: CachePolicy.peopleGroupList,
    refreshAfter: CachePolicy.peopleGroupCounts,
    forceRefresh: forceRefresh,
    decode: _parseList,
    errorMessage: (status) => 'Failed to load people groups ($status)',
  );
}

/// One people group's detail page, cached for
/// [CachePolicy.peopleGroupDetail] and refreshed in the background once the
/// cached copy is older than [CachePolicy.peopleGroupCounts].
///
/// Pass [forceRefresh] for an explicit user retry.
Future<PeopleGroupDetail> fetchPeopleGroupDetail(
  String slug, {
  required String lang,
  bool forceRefresh = false,
}) {
  return getJsonCached(
    uri: ApiConfig.buildUri('/api/people-groups/detail/$slug', {'lang': lang}),
    cacheKey: peopleGroupDetailCacheKey(slug, lang),
    ttl: CachePolicy.peopleGroupDetail,
    refreshAfter: CachePolicy.peopleGroupCounts,
    forceRefresh: forceRefresh,
    decode: (body) =>
        PeopleGroupDetail.fromJson(jsonDecode(body) as Map<String, dynamic>),
    errorMessage: (status) => 'Failed to load people group detail ($status)',
  );
}

/// Loads an already-cached list and detail page into memory so the browse tab
/// and a returning user's own group paint without a skeleton. Never fetches.
Future<void> warmPeopleGroupCaches({
  required String lang,
  String? selectedSlug,
}) async {
  await Future.wait([
    warmCachedValue<List<PeopleGroup>>(
      cacheKey: peopleGroupListCacheKey(lang),
      ttl: CachePolicy.peopleGroupList,
      decode: _parseList,
    ),
    if (selectedSlug != null && selectedSlug.isNotEmpty)
      warmCachedValue<PeopleGroupDetail>(
        cacheKey: peopleGroupDetailCacheKey(selectedSlug, lang),
        ttl: CachePolicy.peopleGroupDetail,
        decode: (body) => PeopleGroupDetail.fromJson(
          jsonDecode(body) as Map<String, dynamic>,
        ),
      ),
  ]);
}

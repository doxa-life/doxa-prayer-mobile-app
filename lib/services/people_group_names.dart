import 'package:flutter/foundation.dart';

import 'locale_controller.dart';
import 'subscribed_people_groups_controller.dart';

/// slug → name, per language code. Names can differ by language, and the
/// people-group list is fetched and cached per language.
final Map<String, Map<String, String>> _names = <String, Map<String, String>>{};

/// Bumped whenever a name is learned, so anything showing one by slug can
/// rebuild — a sheet opened before its group's name was known picks it up as
/// soon as it is.
final ValueNotifier<int> peopleGroupNamesChanged = ValueNotifier<int>(0);

/// The name of the people group [slug], from what the app has already loaded —
/// never a request.
///
/// Every decode of the people-group list publishes every group's name here,
/// and that includes the startup warm of the list's disk cache, so once the
/// list has been fetched once all names are known from the first frame of
/// every later launch. Each detail page adds its own group's name too.
///
/// Prefers the name in [lang] (by default the app's language), then any
/// language it is known in, then the name saved with the user's own
/// subscriptions. Null only for a group the app has never seen.
String? peopleGroupNameFor(String slug, {String? lang}) {
  if (slug.isEmpty) return null;
  final code = lang ?? localeController.value.languageCode;
  final inLang = _names[code]?[slug];
  if (inLang != null) return inLang;
  for (final names in _names.values) {
    final name = names[slug];
    if (name != null) return name;
  }
  return peopleGroupsController.value.bySlug(slug)?.name;
}

/// Records the names in [entries] (slug, name) as [lang]'s. Called from the
/// people-group decodes; not meant for anything else.
void publishPeopleGroupNames(
  String lang,
  Iterable<(String slug, String name)> entries,
) {
  final names = _names.putIfAbsent(lang, () => <String, String>{});
  var changed = false;
  for (final (slug, name) in entries) {
    if (slug.isEmpty || name.isEmpty || names[slug] == name) continue;
    names[slug] = name;
    changed = true;
  }
  if (changed) peopleGroupNamesChanged.value++;
}

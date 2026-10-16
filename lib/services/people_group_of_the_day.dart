import '../models/people_group.dart';
import '../models/prayer_content.dart';
import 'prayer_content_service.dart';

/// Today's People Group of the Day, as named in [slug]'s prayer content, or
/// null when that content names none.
///
/// Read from the same day's prayer content the Pray tab shows, under the same
/// cache key, so it costs no request once either screen has loaded it.
Future<PeopleGroupBlockData?> fetchPeopleGroupOfTheDay({
  required String slug,
  required String language,
}) async {
  final content = await fetchPrayerContent(
    slug: slug,
    date: DateTime.now(),
    language: language,
  );
  for (final block in content.content) {
    if (block.type == PrayerContentBlockType.peopleGroupOfTheDay &&
        block.peopleGroupData != null) {
      return block.peopleGroupData;
    }
  }
  return null;
}

/// The index in [groups] of the People Group of the Day described by [day],
/// or -1. The prayer content gives no slug, so it is matched on name — and on
/// country too when that tells apart groups sharing a name.
int indexOfPeopleGroupOfTheDay(
  List<PeopleGroup> groups,
  PeopleGroupBlockData day,
) {
  String norm(String? s) => (s ?? '').trim().toLowerCase();
  final name = norm(day.name);
  if (name.isEmpty) return -1;
  final country = norm(day.country);
  var byName = -1;
  for (var i = 0; i < groups.length; i++) {
    if (norm(groups[i].name) != name) continue;
    if (country.isEmpty || norm(groups[i].countryLabel) == country) return i;
    if (byName < 0) byName = i;
  }
  return byName;
}

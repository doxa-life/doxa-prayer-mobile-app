class PeopleGroup {
  const PeopleGroup({
    required this.name,
    required this.slug,
    required this.imageUrl,
    required this.countryLabel,
    required this.religionLabel,
    required this.peoplePraying,
    required this.peopleCommitted,
    this.countryCode,
    this.religionCode,
    this.religionAlternates = const [],
    this.primaryLanguageLabel,
    this.population,
    this.resourcesAvailable,
    this.engagementStatusValue,
    this.regionValue,
    this.latitude,
    this.longitude,
  });

  final String name;
  final String slug;
  final String? imageUrl;

  /// ISO country code (e.g. "MYS"). Country labels are display text; codes are
  /// what the country filter matches on.
  final String? countryCode;
  final String? countryLabel;
  final String? religionLabel;

  /// The API's religion code ("MSN", "CPR"…) — untranslated, so it's what
  /// picks the religion's icon.
  final String? religionCode;

  /// Other names for the religion, translated server-side (e.g. "Muslim" and
  /// "Shiite" for "Islam - Shia"). The search box matches these as well as
  /// the label, so typing "muslim" finds every Islam group.
  final List<String> religionAlternates;
  final String? primaryLanguageLabel;
  final int? population;

  /// How many outreach resources exist in the group's language (Bible, Jesus
  /// film, radio, gospel recordings, audio scripture, Bible stories): 0–6, or
  /// null when unknown. Onboarding's "pick a group for me" favours groups
  /// with fewer.
  final int? resourcesAvailable;

  /// Raw API value ("engaged" / "unengaged"), not a display label.
  final String? engagementStatusValue;

  /// Raw API value ("asia", "africa", …), lowercased. Used to group the
  /// country filter by continent.
  final String? regionValue;
  final int peoplePraying;

  /// How many people have committed to pray for this group. Drives the pin's
  /// colour on the map — see `models/prayer_commitment.dart`.
  final int peopleCommitted;

  /// Where the group sits on the map, in degrees. Null for a group the API has
  /// no location for — every group has one today, but the columns are nullable
  /// server-side, so the map button is hidden rather than assuming.
  final double? latitude;
  final double? longitude;

  bool get hasLocation => latitude != null && longitude != null;

  /// The API returns the coordinates as decimal *strings*
  /// (`"5.68736400"`), not numbers — they come straight off a Postgres
  /// NUMERIC column. Accepts either shape so a future change to the response
  /// doesn't silently drop every pin.
  static double? _coordinate(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  /// The API's coordinates as a pair, or nulls when they can't be a real
  /// place: out of range, not finite, or exactly 0,0 — "Null Island", which is
  /// what an unset NUMERIC pair defaults to and would otherwise put a pin in
  /// the Gulf of Guinea for a group that lives somewhere else entirely.
  static (double?, double?) _location(dynamic lat, dynamic lng) {
    final latitude = _coordinate(lat);
    final longitude = _coordinate(lng);
    if (latitude == null || longitude == null) return (null, null);
    if (!latitude.isFinite || !longitude.isFinite) return (null, null);
    if (latitude.abs() > 90 || longitude.abs() > 180) return (null, null);
    if (latitude == 0 && longitude == 0) return (null, null);
    return (latitude, longitude);
  }

  /// `people_committed` comes back as a string too, for the same reason.
  static int _count(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// The six per-resource flags behind `imb_total_resources_available`.
  static const resourceFlagFields = [
    'imb_bible_available',
    'imb_jesus_film_available',
    'imb_radio_broadcast_available',
    'imb_gospel_recordings_available',
    'imb_audio_scripture_available',
    'imb_bible_stories_available',
  ];

  /// The API's total when it has one (a numeric string, like population);
  /// for the ~350 groups where it's null, the count of resource flags that
  /// are true — every group carries those. Null only if neither is present.
  static int? _resources(Map<String, dynamic> json) {
    final total = json['imb_total_resources_available'];
    if (total is num) return total.toInt();
    if (total is String && int.tryParse(total) != null) {
      return int.parse(total);
    }
    final flags = [for (final f in resourceFlagFields) json[f]];
    if (flags.every((v) => v is! bool)) return null;
    return flags.where((v) => v == true).length;
  }

  static PeopleGroup fromJson(Map<String, dynamic> json) {
    final country = json['country_code'];
    final religion = json['religion'];
    final primaryLanguage = json['primary_language'];
    final engagementStatus = json['engagement_status'];
    final region = json['region'];
    final population = json['population'];
    final (latitude, longitude) = _location(
      json['latitude'],
      json['longitude'],
    );
    return PeopleGroup(
      name: json['name'] as String,
      slug: json['slug'] as String,
      imageUrl: json['image_url'] as String?,
      countryCode: country is Map<String, dynamic>
          ? country['value'] as String?
          : null,
      countryLabel: country is Map<String, dynamic>
          ? country['label'] as String?
          : null,
      religionLabel: religion is Map<String, dynamic>
          ? religion['label'] as String?
          : null,
      religionCode: religion is Map<String, dynamic>
          ? religion['value'] as String?
          : null,
      religionAlternates: religion is Map<String, dynamic>
          ? [...?(religion['alternates'] as List?)?.whereType<String>()]
          : const [],
      primaryLanguageLabel: primaryLanguage is Map<String, dynamic>
          ? primaryLanguage['label'] as String?
          : null,
      population: switch (population) {
        num n => n.toInt(),
        String s => int.tryParse(s),
        _ => null,
      },
      resourcesAvailable: _resources(json),
      engagementStatusValue: engagementStatus is Map<String, dynamic>
          ? (engagementStatus['value'] as String?)?.toLowerCase()
          : null,
      regionValue: region is Map<String, dynamic>
          ? (region['value'] as String?)?.toLowerCase()
          : null,
      peoplePraying: (json['people_praying'] as num?)?.toInt() ?? 0,
      peopleCommitted: _count(json['people_committed']),
      latitude: latitude,
      longitude: longitude,
    );
  }
}

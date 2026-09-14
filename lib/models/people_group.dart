class PeopleGroup {
  const PeopleGroup({
    required this.name,
    required this.slug,
    required this.imageUrl,
    required this.countryLabel,
    required this.religionLabel,
    required this.peoplePraying,
    this.latitude,
    this.longitude,
  });

  final String name;
  final String slug;
  final String? imageUrl;
  final String? countryLabel;
  final String? religionLabel;
  final int peoplePraying;

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
    if (value is String) return double.tryParse(value);
    return null;
  }

  static PeopleGroup fromJson(Map<String, dynamic> json) {
    final country = json['country_code'];
    final religion = json['religion'];
    return PeopleGroup(
      name: json['name'] as String,
      slug: json['slug'] as String,
      imageUrl: json['image_url'] as String?,
      countryLabel: country is Map<String, dynamic>
          ? country['label'] as String?
          : null,
      religionLabel: religion is Map<String, dynamic>
          ? religion['label'] as String?
          : null,
      peoplePraying: (json['people_praying'] as num?)?.toInt() ?? 0,
      latitude: _coordinate(json['latitude']),
      longitude: _coordinate(json['longitude']),
    );
  }
}

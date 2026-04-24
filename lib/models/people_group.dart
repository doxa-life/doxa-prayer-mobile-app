class PeopleGroup {
  const PeopleGroup({
    required this.name,
    required this.slug,
    required this.imageUrl,
    required this.countryLabel,
    required this.religionLabel,
    required this.peoplePraying,
  });

  final String name;
  final String slug;
  final String? imageUrl;
  final String? countryLabel;
  final String? religionLabel;
  final int peoplePraying;

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
    );
  }
}

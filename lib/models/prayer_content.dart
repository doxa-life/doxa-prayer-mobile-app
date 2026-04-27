class PrayerContentResponse {
  const PrayerContentResponse({
    required this.peopleGroup,
    required this.date,
    required this.language,
    required this.availableLanguages,
    required this.content,
    required this.hasContent,
  });

  final PrayerContentPeopleGroup peopleGroup;
  final String date;
  final String language;
  final List<String> availableLanguages;
  final List<PrayerContentBlock> content;
  final bool hasContent;

  static PrayerContentResponse fromJson(Map<String, dynamic> json) {
    return PrayerContentResponse(
      peopleGroup: PrayerContentPeopleGroup.fromJson(
        json['people_group'] as Map<String, dynamic>,
      ),
      date: json['date'] as String? ?? '',
      language: json['language'] as String? ?? '',
      availableLanguages:
          (json['availableLanguages'] as List<dynamic>? ?? const [])
              .map((e) => e as String)
              .toList(growable: false),
      content: (json['content'] as List<dynamic>? ?? const [])
          .map((e) => PrayerContentBlock.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      hasContent: json['hasContent'] as bool? ?? false,
    );
  }
}

class PrayerContentPeopleGroup {
  const PrayerContentPeopleGroup({
    required this.id,
    required this.slug,
    required this.title,
    this.imageUrl,
    this.defaultLanguage,
  });

  final int id;
  final String slug;
  final String title;
  final String? imageUrl;
  final String? defaultLanguage;

  static PrayerContentPeopleGroup fromJson(Map<String, dynamic> json) {
    return PrayerContentPeopleGroup(
      id: (json['id'] as num?)?.toInt() ?? 0,
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      defaultLanguage: json['default_language'] as String?,
    );
  }
}

enum PrayerContentBlockType { peopleGroup, static, unknown }

class PrayerContentBlock {
  const PrayerContentBlock({
    required this.id,
    required this.title,
    required this.languageCode,
    required this.type,
    this.contentJson,
    this.peopleGroupData,
  });

  final int id;
  final String title;
  final String languageCode;
  final PrayerContentBlockType type;
  final Map<String, dynamic>? contentJson;
  final PeopleGroupBlockData? peopleGroupData;

  static PrayerContentBlock fromJson(Map<String, dynamic> json) {
    final rawType = json['content_type'] as String? ?? '';
    final type = switch (rawType) {
      'people_group' => PrayerContentBlockType.peopleGroup,
      'static' => PrayerContentBlockType.static,
      _ => PrayerContentBlockType.unknown,
    };
    final pgRaw = json['people_group_data'];
    return PrayerContentBlock(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      languageCode: json['language_code'] as String? ?? '',
      type: type,
      contentJson: json['content_json'] as Map<String, dynamic>?,
      peopleGroupData: pgRaw is Map<String, dynamic>
          ? PeopleGroupBlockData.fromJson(pgRaw)
          : null,
    );
  }
}

class PeopleGroupBlockData {
  const PeopleGroupBlockData({
    required this.name,
    required this.description,
    required this.pictureCredit,
    this.imageUrl,
    this.population,
    this.language,
    this.religion,
    this.country,
    this.lat,
    this.lng,
  });

  final String name;
  final String description;
  final List<PictureCredit> pictureCredit;
  final String? imageUrl;
  final int? population;
  final String? language;
  final String? religion;
  final String? country;
  final double? lat;
  final double? lng;

  static PeopleGroupBlockData fromJson(Map<String, dynamic> json) {
    return PeopleGroupBlockData(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      population: (json['population'] as num?)?.toInt(),
      language: json['language'] as String?,
      religion: json['religion'] as String?,
      country: json['country'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      pictureCredit: (json['picture_credit'] as List<dynamic>? ?? const [])
          .map((e) => PictureCredit.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class PictureCredit {
  const PictureCredit({required this.text, this.link});

  final String text;
  final String? link;

  static PictureCredit fromJson(Map<String, dynamic> json) {
    return PictureCredit(
      text: json['text'] as String? ?? '',
      link: json['link'] as String?,
    );
  }
}

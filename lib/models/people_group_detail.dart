class PictureCreditSegment {
  const PictureCreditSegment({this.text, this.link});

  final String? text;
  final String? link;

  static PictureCreditSegment fromJson(Map<String, dynamic> json) =>
      PictureCreditSegment(
        text: json['text'] as String?,
        link: json['link'] as String?,
      );
}

class PeopleGroupDetail {
  const PeopleGroupDetail({required this.raw});

  final Map<String, dynamic> raw;

  String get name => raw['name'] as String? ?? '';
  String get slug => raw['slug'] as String? ?? '';
  String? get imageUrl => raw['image_url'] as String?;

  List<PictureCreditSegment> get pictureCredit {
    final value = raw['picture_credit'];
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(PictureCreditSegment.fromJson)
        .toList(growable: false);
  }

  int get peopleCommitted {
    final v = raw['people_committed'];
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  int get peoplePraying {
    final v = raw['people_praying'];
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static PeopleGroupDetail fromJson(Map<String, dynamic> json) =>
      PeopleGroupDetail(raw: json);
}

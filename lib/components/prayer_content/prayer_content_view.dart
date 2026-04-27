import 'package:flutter/material.dart';

import '../../models/prayer_content.dart';
import '../../theme/app_spacing.dart';
import 'people_group_intro_view.dart';
import 'prayer_doc_view.dart';

/// Renders a full `PrayerContentResponse` as a vertical stack of
/// content blocks: people-group introductions and static rich-text docs.
class PrayerContentView extends StatelessWidget {
  const PrayerContentView({super.key, required this.response});

  final PrayerContentResponse response;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final block in response.content) {
      final widget = _buildBlock(block);
      if (widget != null) children.add(widget);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.xxl,
      children: children,
    );
  }

  Widget? _buildBlock(PrayerContentBlock block) {
    switch (block.type) {
      case PrayerContentBlockType.peopleGroup:
        final data = block.peopleGroupData;
        if (data == null) return null;
        return PeopleGroupIntroView(name: block.title, data: data);
      case PrayerContentBlockType.static:
        final doc = block.contentJson;
        if (doc == null) return null;
        return PrayerDocView(doc: doc);
      case PrayerContentBlockType.unknown:
        return null;
    }
  }
}

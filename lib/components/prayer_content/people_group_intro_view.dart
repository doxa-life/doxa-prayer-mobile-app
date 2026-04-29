import 'package:flutter/material.dart';

import '../../models/prayer_content.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/app_image.dart';
import '../misc/titles.dart';

/// Renders the introductory `people_group` block of a prayer-content
/// response — used at the top of the pray screen, and reusable on the
/// people-group details / wizard preview screens.
class PeopleGroupIntroView extends StatelessWidget {
  const PeopleGroupIntroView({
    super.key,
    required this.name,
    required this.data,
  });

  final String name;
  final PeopleGroupBlockData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: AppSpacing.lg,
      children: [
        H1(name, textAlign: TextAlign.center),
        AppImage(url: data.imageUrl, aspectRatio: 1, size: 169.0),
        if (data.description.isNotEmpty)
          Text(data.description, style: AppTypography.bodyMedium),
      ],
    );
  }
}

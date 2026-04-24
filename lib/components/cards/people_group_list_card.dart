import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../buttons/action_button.dart';
import '../buttons/button_link.dart';
import '../misc/app_image.dart';
import 'elevated_card.dart';

class PeopleGroupListCard extends StatelessWidget {
  const PeopleGroupListCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.onPray,
    required this.onDetails,
  });

  final String name;
  final String? imageUrl;
  final VoidCallback onPray;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return ElevatedAppCard(
      padding: AppSpacing.xl,
      child: Column(
        spacing: AppSpacing.sm,
        children: [
          Row(
            spacing: AppSpacing.md,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AppImage(url: imageUrl, aspectRatio: 1, size: 96.0),
              Expanded(
                child: Text(
                  name,
                  softWrap: true,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: AppSpacing.md,
            children: [
              ButtonLink(label: 'Profile', onPressed: onDetails),
              ActionButton(
                label: 'Pray',
                onPressed: onPray,
                color: ActionButtonColor.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

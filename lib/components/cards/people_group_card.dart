import 'package:doxa_prayer_mobile_app/components/buttons/icon_label_button.dart';
import 'package:doxa_prayer_mobile_app/components/misc/app_icon.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../misc/app_image.dart';
import 'elevated_card.dart';

class PeopleGroupCard extends StatelessWidget {
  const PeopleGroupCard({
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: AppSpacing.xl,
        children: [
          Text(name, style: AppTypography.h2),
          AppImage(url: imageUrl, aspectRatio: 1, size: 169.0),
          ActionButton(
            label: 'Pray',
            onPressed: onPray,
            color: ActionButtonColor.secondary,
          ),
          Row(
            spacing: AppSpacing.md,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconLabelButton(
                icon: const AppIcon(AppIconName.person),
                label: 'Profile',
                onPressed: () {},
              ),
              IconLabelButton(
                icon: const AppIcon(AppIconName.share),
                label: 'Share',
                onPressed: () {},
              ),
              IconLabelButton(
                icon: const AppIcon(AppIconName.trash),
                label: 'Remove',
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

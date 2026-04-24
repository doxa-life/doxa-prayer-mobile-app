import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../buttons/button_link.dart';
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
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _PeopleGroupImage(imageUrl: imageUrl),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.h2),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ButtonLink(label: 'Profile', onPressed: onDetails),
                    ActionButton(label: 'Pray', onPressed: onPray),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeopleGroupImage extends StatelessWidget {
  const _PeopleGroupImage({required this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(imageUrl!, fit: BoxFit.cover);
    }
    return Container(
      color: AppColors.mutedSurface,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 48,
        color: AppColors.onSurface.withValues(alpha: 0.4),
      ),
    );
  }
}

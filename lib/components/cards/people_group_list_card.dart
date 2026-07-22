import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
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
    required this.onSelect,
    required this.onDetails,
    this.isSelected = false,
  });

  final String name;
  final String? imageUrl;
  final VoidCallback onSelect;
  final VoidCallback onDetails;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          // A Wrap (rather than a Row) so the profile link and select button
          // reflow onto separate lines instead of overflowing when a long
          // label or a large font scale leaves them no room side by side.
          // Full width so spaceBetween keeps profile left / select right while
          // they fit on one line.
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                ButtonLink(
                  label: l10n.profile,
                  onPressed: onDetails,
                ),
                ActionButton(
                  label: isSelected ? l10n.selected : l10n.select,
                  onPressed: isSelected ? null : onSelect,
                  color: ActionButtonColor.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

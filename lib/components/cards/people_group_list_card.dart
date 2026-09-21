import 'package:doxa_prayer_mobile_app/theme/app_colors.dart';
import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../buttons/action_button.dart';
import '../buttons/button_link.dart';
import '../misc/app_image.dart';
import 'elevated_card.dart';
import '../misc/hyphenated_text.dart';

class PeopleGroupListCard extends StatelessWidget {
  const PeopleGroupListCard({
    super.key,
    required this.name,
    required this.country,
    required this.imageUrl,
    required this.onSelect,
    required this.onDetails,
    this.onUnselect,
    this.isSelected = false,
  });

  final String name;
  final String country;
  final String? imageUrl;
  final VoidCallback onSelect;
  final VoidCallback onDetails;

  /// What an already-selected group's button does. When null the button falls
  /// back to an inert "Selected" — the wizard passes null, because unselecting
  /// the group being chosen mid-onboarding has nowhere sensible to go.
  final VoidCallback? onUnselect;
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
              AppImage(url: imageUrl, size: 96.0, semanticLabel: name),
              Expanded(
                child: Column(
                  spacing: 0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    HyphenatedText(
                      name,
                      softWrap: true,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    HyphenatedText(
                      country,
                      softWrap: true,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w300,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
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
                ButtonLink(label: l10n.profile, onPressed: onDetails),
                ActionButton(
                  // A selected group's button offers the action it performs
                  // rather than restating the state the card already shows.
                  label: isSelected
                      ? (onUnselect == null ? l10n.selected : l10n.unselect)
                      : l10n.select,
                  onPressed: isSelected ? onUnselect : onSelect,
                  // Quieter than the green select: removing a commitment should
                  // not be the most inviting thing on the card.
                  color: isSelected
                      ? ActionButtonColor.white
                      : ActionButtonColor.secondary,
                  isOutlined: isSelected,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

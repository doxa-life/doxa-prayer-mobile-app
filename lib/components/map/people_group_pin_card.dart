import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/people_group.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../buttons/button_link.dart';
import '../cards/elevated_card.dart';
import '../misc/app_image.dart';
import '../misc/hyphenated_text.dart';
import '../misc/prayed_today_pill.dart';
import '../misc/selected_pill.dart';

/// The card that identifies whichever pin is currently selected on the
/// people-group map.
///
/// Sits at the bottom of the map rather than floating beside its pin: a popup
/// anchored to the pin would cover the neighbours the user is comparing it
/// with, and at phone width it would spend most of its life colliding with a
/// screen edge.
class PeopleGroupPinCard extends StatelessWidget {
  const PeopleGroupPinCard({
    super.key,
    required this.group,
    required this.isSubscribed,
    required this.prayedToday,
    required this.onPray,
    required this.onProfile,
    required this.onClose,
  });

  final PeopleGroup group;

  /// Whether the user prays for this group — the same state the pin's accent
  /// fill shows on the map.
  final bool isSubscribed;
  final bool prayedToday;

  final VoidCallback onPray;
  final VoidCallback onProfile;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ElevatedAppCard(
      padding: AppSpacing.xl,
      // The card holds its own controls, so its contents must stay as separate
      // accessibility stops rather than collapsing into one node.
      mergeSemantics: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.sm,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.md,
            children: [
              // Same treatment as the browse list's card. AppImage shows a
              // skeleton while the photo loads and falls back to a placeholder
              // when there isn't one, so the row never changes height.
              AppImage(
                url: group.imageUrl,
                size: 64.0,
                semanticLabel: group.name,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.xs,
                  children: [
                    HyphenatedText(
                      group.name,
                      softWrap: true,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (group.countryLabel != null)
                      HyphenatedText(
                        group.countryLabel!,
                        softWrap: true,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w300,
                          color: AppColors.primaryLight,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.primary),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: onClose,
              ),
            ],
          ),
          // Status, when there is any to report. Kept on the card rather than
          // on the pins: at pin size there is room for a colour and nothing
          // else. Full card width — running under the photo rather than beside
          // it — so both pills fit on one line and only wrap when they truly
          // cannot, such as at a large font scale.
          if (isSubscribed || prayedToday)
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  if (isSubscribed) SelectedPill(label: l.selected),
                  if (prayedToday) PrayedTodayPill(label: l.prayedToday),
                ],
              ),
            ),
          // A Wrap so the link and button reflow onto separate lines instead of
          // overflowing at large font scales, matching the people-group cards.
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                ButtonLink(label: l.profile, onPressed: onProfile),
                ActionButton(
                  label: l.pray,
                  onPressed: onPray,
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

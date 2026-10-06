import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../buttons/action_button.dart';
import '../misc/app_icon.dart';
import '../misc/app_image.dart';
import 'elevated_card.dart';
import '../misc/hyphenated_text.dart';

class PeopleGroupListCard extends StatelessWidget {
  const PeopleGroupListCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.onDetails,
    this.onSelect,
    this.onUnselect,
    this.countryLabel,
    this.isSelected = false,
    this.engagementStatusValue,
    this.peoplePraying = 0,
    this.showSelectButton = false,
  });

  final String name;
  final String? imageUrl;
  final VoidCallback onDetails;

  /// Only used when [showSelectButton] is true (the wizard).
  final VoidCallback? onSelect;

  /// What an already-selected group's button does. When null the button is an
  /// inert "Selected" — the wizard passes null.
  final VoidCallback? onUnselect;

  /// The same ethnolinguistic people group is often tracked as a separate
  /// entry per country, so the country is shown under the name to tell
  /// same-named entries apart.
  final String? countryLabel;

  /// Whether the user already follows this group.
  final bool isSelected;

  /// Raw API value ("engaged" / "unengaged"). Shown as a status pill.
  final String? engagementStatusValue;
  final int peoplePraying;

  /// The wizard's onboarding list still needs a quick in-list select. The
  /// standalone search list keeps the card as the only tap target.
  final bool showSelectButton;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ElevatedAppCard(
      padding: AppSpacing.xl,
      onTap: onDetails,
      mergeSemantics: false,
      child: Column(
        spacing: AppSpacing.sm,
        children: [
          Row(
            spacing: AppSpacing.md,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AppImage(url: imageUrl, size: 96.0, semanticLabel: name),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppSpacing.xxs,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSpacing.sm,
                      children: [
                        Expanded(
                          child: HyphenatedText(
                            name,
                            softWrap: true,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isSelected && !showSelectButton)
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                      ],
                    ),
                    if (countryLabel != null) _CountryTag(label: countryLabel!),
                    if (engagementStatusValue != null)
                      _StatusPill(
                        engaged: engagementStatusValue == 'engaged',
                      ),
                    _PrayingCount(count: peoplePraying),
                  ],
                ),
              ),
            ],
          ),
          // Select button reflows onto a separate line instead of overflowing
          // when a large font scale leaves it no room.
          if (showSelectButton)
            SizedBox(
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerRight,
                child: ActionButton(
                  label: isSelected
                      ? (onUnselect == null ? l10n.selected : l10n.unselect)
                      : l10n.select,
                  onPressed: isSelected ? onUnselect : onSelect,
                  color: isSelected
                      ? ActionButtonColor.white
                      : ActionButtonColor.secondary,
                  isOutlined: isSelected,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small "Engaged"/"Unengaged" pill — a subtle tinted chip, using the same
/// colours as the profile page's engagement markers.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.engaged});

  final bool engaged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final color = engaged ? scheme.secondary : scheme.error;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.xxs,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            HyphenatedText(
              engaged ? l10n.engaged : l10n.unengaged,
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryTag extends StatelessWidget {
  const _CountryTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.6);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.xxxs,
      children: [
        Icon(Icons.place_outlined, size: 14, color: muted),
        Flexible(
          child: HyphenatedText(
            label,
            softWrap: true,
            style: AppTypography.caption.copyWith(color: muted),
          ),
        ),
      ],
    );
  }
}

class _PrayingCount extends StatelessWidget {
  const _PrayingCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final color = count > 0
        ? scheme.secondary
        : scheme.onSurface.withValues(alpha: 0.6);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.xxxs,
      children: [
        AppIcon(AppIconName.pray, size: 14, color: color),
        HyphenatedText(
          l10n.nPeoplePraying(count),
          style: AppTypography.caption.copyWith(
            color: color,
            fontWeight: count > 0 ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

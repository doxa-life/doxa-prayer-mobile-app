import 'dart:math' as math;

import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../buttons/action_button.dart';
import '../misc/app_icon.dart';
import '../misc/app_image.dart';
import 'elevated_card.dart';
import '../misc/country_flag.dart';
import '../misc/engagement_status_pill.dart';
import '../misc/hyphenated_text.dart';

class PeopleGroupListCard extends StatelessWidget {
  const PeopleGroupListCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.onDetails,
    this.onSelect,
    this.onDeselect,
    this.countryLabel,
    this.countryCode,
    this.isSelected = false,
    this.engagementStatusValue,
    this.peoplePraying = 0,
    this.showSelectButton = false,
    this.tag,
  });

  final String name;
  final String? imageUrl;
  final VoidCallback onDetails;

  /// Only used when [showSelectButton] is true (the wizard).
  final VoidCallback? onSelect;

  /// What tapping an already-selected group's "Selected" button does. When
  /// null the button is inert — the wizard passes null.
  final VoidCallback? onDeselect;

  /// The same ethnolinguistic people group is often tracked as a separate
  /// entry per country, so the country is shown under the name to tell
  /// same-named entries apart.
  final String? countryLabel;

  /// ISO alpha-3 code ("MYS"); its flag is shown after [countryLabel].
  final String? countryCode;

  /// Whether the user already follows this group.
  final bool isSelected;

  /// Raw API value ("engaged" / "unengaged"). Shown as a status pill.
  final String? engagementStatusValue;
  final int peoplePraying;

  /// The wizard's onboarding list still needs a quick in-list select. The
  /// standalone search list keeps the card as the only tap target.
  final bool showSelectButton;

  /// A label pinned to the top of the card saying why it stands out — the
  /// People Group of the Day.
  final String? tag;

  static final TextStyle _nameStyle = AppTypography.bodyMedium.copyWith(
    fontWeight: FontWeight.w500,
  );

  /// Lines the name may take. The longest UUPG name is 33 characters, which
  /// fits in two at the default text size.
  static const int _nameLines = 2;

  /// The height of the details beside the photo when the name takes all its
  /// lines and every line under it is there. Every card reserves it, so cards
  /// are the same height whether a name wraps or not, and whether or not a
  /// group has an engagement status.
  static double _detailsHeight(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    double linesOf(TextStyle style, int lines) {
      final painter = TextPainter(
        text: TextSpan(text: List.filled(lines, 'Ag').join('\n'), style: style),
        textDirection: direction,
        textScaler: scaler,
      )..layout();
      final height = painter.height;
      painter.dispose();
      return height;
    }

    final caption = linesOf(AppTypography.caption, 1);
    final pill =
        linesOf(
          AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
          1,
        ) +
        AppSpacing.xxxs * 2;
    return linesOf(_nameStyle, _nameLines) +
        // The country line, with its pin icon and flag.
        math.max(caption, 14) +
        pill +
        // The praying count, with its icon.
        math.max(caption, 14) +
        AppSpacing.xxs * 3;
  }

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
          if (tag != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: _Tag(label: tag!),
            ),
          Row(
            spacing: AppSpacing.md,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AppImage(url: imageUrl, size: 96.0, semanticLabel: name),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: _detailsHeight(context),
                  ),
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
                              maxLines: _nameLines,
                              overflow: TextOverflow.ellipsis,
                              style: _nameStyle,
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
                      if (countryLabel != null)
                        _CountryTag(label: countryLabel!, code: countryCode),
                      if (engagementStatusValue != null)
                        EngagementStatusPill(
                          engaged: engagementStatusValue == 'engaged',
                        ),
                      _PrayingCount(count: peoplePraying),
                    ],
                  ),
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
                // Selected, it says so rather than offering a negative
                // "Deselect"; screen readers still hear what a tap does.
                child: Semantics(
                  hint: isSelected && onDeselect != null ? l10n.deselect : null,
                  child: ActionButton(
                    label: isSelected ? l10n.selected : l10n.select,
                    onPressed: isSelected ? onDeselect : onSelect,
                    color: isSelected
                        ? ActionButtonColor.white
                        : ActionButtonColor.secondary,
                    isOutlined: isSelected,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
        child: HyphenatedText(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CountryTag extends StatelessWidget {
  const _CountryTag({required this.label, this.code});

  final String label;
  final String? code;

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
        // One line, so a long country name can't make its card taller than
        // the rest; the card's height is reserved for exactly one.
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(color: muted),
          ),
        ),
        if (code != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: AppSpacing.xxs),
            child: CountryFlag(code: code!),
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
        Flexible(
          child: Text(
            l10n.nPeoplePraying(count),
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: count > 0 ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

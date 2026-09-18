import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/prayer_commitment.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/prayer_commitment_colors.dart';
import 'heart_glyph.dart';

/// Diameter of a legend swatch. Larger than the pins it explains — a 5px dot
/// reproduced exactly would be unreadable next to text.
const double _swatchSize = 14.0;

/// Explains what the map's pin colours and shapes mean.
///
/// Without it the colours are just decoration: nothing else on the map says
/// that red means nobody has committed to pray for that group.
class MapLegend extends StatelessWidget {
  const MapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // Locale-aware digits, so the thresholds read correctly in scripts that
    // don't use Western Arabic numerals.
    final number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toString(),
    );
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.peopleCommittedToPraying,
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          // The three bands sit on one line — they are short, and stacking them
          // cost the map three rows of height for nothing. A Wrap rather than a
          // Row so they still break cleanly at large font scales.
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: 2,
            children: [
              _row(
                swatch: _dot(PrayerCommitmentLevel.none.color),
                label: number.format(0),
              ),
              _row(
                swatch: _dot(PrayerCommitmentLevel.some.color),
                label:
                    '${number.format(1)}–'
                    '${number.format(kPeopleCommittedGoal - 1)}',
              ),
              _row(
                swatch: _dot(PrayerCommitmentLevel.met.color),
                label: '${number.format(kPeopleCommittedGoal)}+',
              ),
            ],
          ),
          const SizedBox(height: 2),
          _row(
            // The same icon the pins and the "Selected" pill use.
            swatch: const Icon(
              kHeartIcon,
              size: _swatchSize,
              color: AppColors.primaryLight,
            ),
            label: l.yourPeopleGroups,
          ),
        ],
      ),
    );
  }

  Widget _row({required Widget swatch, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _swatchSize,
          height: _swatchSize,
          child: Center(child: swatch),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }

  /// A commitment-colour dot, drawn the way the map draws its circular pins.
  Widget _dot(Color color) => Container(
    width: _swatchSize,
    height: _swatchSize,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.white, width: 1.5),
    ),
  );
}

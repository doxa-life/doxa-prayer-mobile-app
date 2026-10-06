import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_typography.dart';
import '../misc/hyphenated_text.dart';

/// A population range picker. Values are always expressed in actual
/// population units (not a 0..1 slider fraction) — [value] and the range
/// passed to [onChanged] are population counts, e.g. `RangeValues(4, 5000)`.
/// Internally mapped onto the slider on a log scale, since real-world people
/// group populations span several orders of magnitude (single digits to tens
/// of millions in this dataset) — a linear slider would make the small end of
/// the range unusably imprecise.
class PopulationRangeField extends StatelessWidget {
  const PopulationRangeField({
    super.key,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
  });

  /// Absolute lower/upper bounds of the slider (the full, unfiltered range —
  /// typically the min/max population across all loaded groups).
  final int min;
  final int max;

  /// The currently selected range, in population units.
  final RangeValues value;
  final ValueChanged<RangeValues> onChanged;

  double _logOf(num n) => math.log(math.max(n, 1));

  double _toSlider(double population) {
    final lo = _logOf(min);
    final hi = _logOf(max);
    if (hi <= lo) return 0;
    return ((_logOf(population) - lo) / (hi - lo)).clamp(0, 1);
  }

  double _fromSlider(double t) {
    final lo = _logOf(min);
    final hi = _logOf(max);
    return math.exp(lo + t * (hi - lo));
  }

  /// Division count for the slider, sized to the actual log-span of
  /// [min]..[max] rather than a fixed number. A fixed division count (this
  /// used to be a flat 100) means each snap-step is a fixed *fraction of the
  /// whole range* — but the range is log-scaled and this dataset spans single
  /// digits to well over a billion, so a fixed 100 steps made each step a
  /// ~15-20% multiplicative jump in population, which reads as the slider
  /// "scaling way too quickly". Sizing steps to a small, constant multiplicative
  /// change instead (~1.5% per step) keeps dragging smooth regardless of how
  /// wide the loaded dataset's range turns out to be.
  int get _divisions {
    final span = _logOf(max) - _logOf(min);
    if (span <= 0) return 1;
    const targetStepLog = 0.015;
    return (span / targetStepLog).round().clamp(100, 2000);
  }

  static String _format(double population) {
    final n = population.round();
    return n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final sliderValues = RangeValues(
      _toSlider(value.start),
      _toSlider(value.end),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HyphenatedText(
          l.population,
          style: AppTypography.bodyMedium.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        RangeSlider(
          values: sliderValues,
          divisions: _divisions,
          labels: RangeLabels(_format(value.start), _format(value.end)),
          onChanged: (v) => onChanged(
            RangeValues(_fromSlider(v.start), _fromSlider(v.end)),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HyphenatedText(_format(value.start), style: AppTypography.caption),
            HyphenatedText(_format(value.end), style: AppTypography.caption),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import 'action_button.dart';

/// Bottom button group used by the wizard steps.
///
/// Lays the two buttons out side by side (equal width) when their labels fit
/// on one line, and stacks them full width when a long (e.g. translated) label
/// would otherwise overflow the row.
class ButtonBar extends StatelessWidget {
  const ButtonBar({
    super.key,
    required this.leading,
    required this.trailing,
    this.spacing = AppSpacing.md,
    this.maxWidth,
  });

  /// Left/secondary action (e.g. back, skip).
  final ActionButton leading;

  /// Right/primary action (e.g. save, continue, finish).
  final ActionButton trailing;

  final double spacing;

  /// Available width to lay out within. When null, a [LayoutBuilder] measures
  /// it. Pass an explicit value when this bar lives inside an [IntrinsicHeight]
  /// (e.g. a scrollable wizard step) — [LayoutBuilder] cannot report intrinsic
  /// dimensions and would break the surrounding intrinsic-height measurement.
  final double? maxWidth;

  /// Horizontal chrome (padding + border) a label button occupies on top of
  /// its text. A deliberate over-estimate so we stack just before overflowing
  /// rather than just after.
  static const double _buttonChrome = 56.0;

  double _labelWidth(BuildContext context, String label) {
    final style = Theme.of(context).textTheme.labelLarge;
    final painter = TextPainter(
      text: TextSpan(text: label.toUpperCase(), style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    return painter.width + _buttonChrome;
  }

  Widget _layout(BuildContext context, double maxWidth) {
    final needed =
        _labelWidth(context, leading.label) +
        _labelWidth(context, trailing.label) +
        spacing;

    if (needed <= maxWidth) {
      return Row(
        children: [
          Expanded(child: leading),
          SizedBox(width: spacing),
          Expanded(child: trailing),
        ],
      );
    }

    // Stacked, full width. Primary action sits on top.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        trailing,
        SizedBox(height: spacing),
        leading,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = maxWidth;
    if (width != null) {
      return _layout(context, width);
    }
    return LayoutBuilder(
      builder: (context, constraints) => _layout(context, constraints.maxWidth),
    );
  }
}

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class ElevatedAppCard extends StatelessWidget {
  const ElevatedAppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = AppSpacing.xxxl,
    this.color = AppColors.surface,
    this.mergeSemantics = true,
  });

  final Widget child;
  final double padding;
  final VoidCallback? onTap;
  final Color color;

  /// When the whole card is tappable, merge its contents into a single
  /// semantics node so screen readers announce it as one button (matching
  /// [FilledButton] and friends) rather than exposing each text line plus a
  /// separate, unannounced whole-card tap target.
  ///
  /// Set to false for cards that contain their own independently-operable
  /// controls (e.g. a [Switch]), which must stay as distinct nodes.
  final bool mergeSemantics;

  @override
  Widget build(BuildContext context) {
    Widget tappable = Semantics(
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(padding: EdgeInsets.all(padding), child: child),
      ),
    );

    if (onTap != null && mergeSemantics) {
      tappable = MergeSemantics(child: tappable);
    }

    return Material(
      color: color,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(16),
      child: tappable,
    );
  }
}

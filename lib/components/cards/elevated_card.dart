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
    Widget content = Padding(padding: EdgeInsets.all(padding), child: child);

    // Only a tappable card wraps its contents in an InkWell + button semantics.
    // For a non-tappable card those wrappers would still collapse every line of
    // text into a single merged semantics node, so a screen reader reads the
    // whole card at once instead of stopping on each item; leaving the padded
    // child bare keeps its elements as individual accessibility stops.
    if (onTap != null) {
      content = Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: content,
        ),
      );
      // Announce the whole card as one button (matching [FilledButton] and
      // friends). Skipped for cards with their own operable controls.
      if (mergeSemantics) {
        content = MergeSemantics(child: content);
      }
    }

    return Material(
      color: color,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(16),
      child: content,
    );
  }
}

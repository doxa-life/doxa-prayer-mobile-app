import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class PageContainer extends StatelessWidget {
  const PageContainer({
    super.key,
    required this.child,
    this.maxWidth = 960,
    this.horizontalPadding = AppSpacing.xl,
    this.verticalPadding = AppSpacing.xxl,
    this.bottomPadding,
  });

  final Widget child;
  final double maxWidth;
  final double horizontalPadding;
  final double verticalPadding;

  /// Overrides [verticalPadding] for the bottom edge only. Use 0 when a
  /// scrollable child should reach the bottom of the viewport and carry its
  /// own end padding instead.
  final double? bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.only(
            left: horizontalPadding,
            right: horizontalPadding,
            top: verticalPadding,
            bottom: bottomPadding ?? verticalPadding,
          ),
          child: child,
        ),
      ),
    );
  }
}

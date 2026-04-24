import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class PageContainer extends StatelessWidget {
  const PageContainer({
    super.key,
    required this.child,
    this.maxWidth = 480,
    this.horizontalPadding = AppSpacing.xl,
    this.verticalPadding = AppSpacing.xxl,
  });

  final Widget child;
  final double maxWidth;
  final double horizontalPadding;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: child,
        ),
      ),
    );
  }
}

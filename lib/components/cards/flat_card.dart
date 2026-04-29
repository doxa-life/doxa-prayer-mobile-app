import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class FlatCard extends StatelessWidget {
  const FlatCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xxxl),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

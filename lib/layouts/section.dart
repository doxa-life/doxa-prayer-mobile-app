import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

import '../components/misc/titles.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'spacing.dart';

class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.title,
    required this.child,
    this.description,
  });

  final String title;
  final String? description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.lg,
        children: [
          H2(title),
          if (description != null) ...[
            Text(
              description!,
              style: AppTypography.caption.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
          child,
          const Divider(height: 1),
        ],
      ),
    );
  }
}

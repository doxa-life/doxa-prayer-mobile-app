import 'package:flutter/material.dart';

import '../../layouts/page_scaffold.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../misc/skeleton_box.dart';
import '../misc/skeleton_line.dart';
import '../misc/skeleton_paragraph.dart';

/// Loading placeholder for a day's prayer content, standing in for the shape
/// [PrayerContentView] renders: an intro heading and portrait, a couple of
/// prayer blocks, and the Amen button.
class PrayerContentSkeleton extends StatelessWidget {
  const PrayerContentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // Sits in the Pray screen's scroll, as the real content does.
    return ColoredBox(
      color: AppColors.surface,
      child: PageContainer(
        bottomPadding: AppSpacing.xxxl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.xxl,
          children: [
            // People-group intro: centred title over a square portrait.
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: AppSpacing.lg,
              children: const [
                FractionallySizedBox(
                  widthFactor: 0.8,
                  child: SkeletonLine(height: 20),
                ),
                SkeletonBox(width: 169, height: 169, radius: 16),
              ],
            ),
            // Prayer blocks.
            const SkeletonParagraph(lines: 4),
            const SkeletonParagraph(lines: 3, lastLineWidthFactor: 0.45),
            // Amen button.
            const Center(
              child: SkeletonBox(width: 160, height: 36, radius: 28),
            ),
          ],
        ),
      ),
    );
  }
}

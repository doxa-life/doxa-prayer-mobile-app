import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../cards/profile_cards.dart';
import '../misc/skeleton_box.dart';

/// Loading placeholder for the people-group details screen: the same page of
/// cards the profile is shown in, with placeholders laid out as the first card
/// is — its name and the facts under it, its photo and the select button — and
/// the overview card under it. So the profile lands where its placeholder
/// was.
class PeopleGroupDetailsSkeleton extends StatelessWidget {
  const PeopleGroupDetailsSkeleton({super.key});

  /// As the profile caps its photo — see `_Hero.maxImageWidth`.
  static const double _maxImageWidth = 480;

  @override
  Widget build(BuildContext context) {
    return ProfileStack(
      interactive: false,
      cards: [
        ProfileCard(
          padding: AppSpacing.lg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The name, then the country, region and status under it.
              const Center(child: SkeletonBox(width: 200, height: 44)),
              const SizedBox(height: AppSpacing.sm),
              const Center(child: SkeletonBox(width: 140, height: 20)),
              const SizedBox(height: AppSpacing.xs),
              const Center(child: SkeletonBox(width: 180, height: 16)),
              const SizedBox(height: AppSpacing.lg),
              // The photo, in the 4:5 space it holds while loading.
              LayoutBuilder(
                builder: (context, box) {
                  final width = math.min(box.maxWidth, _maxImageWidth);
                  return Center(
                    child: SkeletonBox(
                      width: width,
                      height: width * 5 / 4,
                      radius: 16,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              // The select button.
              const SkeletonBox(height: 56, radius: 12),
            ],
          ),
        ),
        // The overview card that comes next — description and facts — dark
        // green.
        const ProfileCard(
          color: AppColors.primary,
          child: SizedBox(height: 200),
        ),
      ],
    );
  }
}

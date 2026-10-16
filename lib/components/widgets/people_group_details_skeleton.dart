import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../cards/profile_deck.dart';
import '../misc/skeleton_box.dart';

/// Loading placeholder for the people-group details screen: the same deck the
/// profile is shown in, with placeholders laid out as the first card is — its
/// name and the facts under it, its photo filling the card, the select button
/// and the description — and the next (dark green) card showing beside it. So
/// the profile lands exactly where its placeholder was.
class PeopleGroupDetailsSkeleton extends StatelessWidget {
  const PeopleGroupDetailsSkeleton({super.key});

  /// Five, as the profile has: the dots under the card are drawn too.
  static const int _cardCount = 5;

  @override
  Widget build(BuildContext context) {
    return ProfileDeck(
      interactive: false,
      cards: [
        ProfileDeckCard(
          padding: AppSpacing.xl,
          fill: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The name, then the country and status under it.
              const Center(child: SkeletonBox(width: 200, height: 44)),
              const SizedBox(height: AppSpacing.sm),
              const Center(child: SkeletonBox(width: 140, height: 20)),
              const SizedBox(height: AppSpacing.xs),
              const Center(child: SkeletonBox(width: 180, height: 16)),
              const SizedBox(height: AppSpacing.md),
              const Expanded(child: SkeletonBox(radius: 16)),
              const SizedBox(height: AppSpacing.lg),
              // The select button.
              const SkeletonBox(height: 56, radius: 12),
              const SizedBox(height: AppSpacing.lg),
              for (final width in const [1.0, 1.0, 0.6])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                  child: FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: width,
                    child: const SkeletonBox(height: 20),
                  ),
                ),
            ],
          ),
        ),
        // The rest of the cards are dark green.
        for (var i = 1; i < _cardCount; i++)
          const ProfileDeckCard(
            color: AppColors.primary,
            child: SizedBox.shrink(),
          ),
      ],
      darkCards: {for (var i = 1; i < _cardCount; i++) i},
    );
  }
}

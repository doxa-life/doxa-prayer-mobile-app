import 'package:flutter/material.dart';

import '../cards/detail_section_card_skeleton.dart';
import '../cards/people_group_hero_card_skeleton.dart';
import '../cards/profile_cards.dart';
import '../misc/skeleton_box.dart';

/// Loading placeholder for the people-group details screen: the select button,
/// the hero card, and the stacked detail sections below it — in the same page
/// the profile is shown in, so the profile lands where its placeholder was.
class PeopleGroupDetailsSkeleton extends StatelessWidget {
  const PeopleGroupDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // Not interactive: there is nothing below the fold yet, and a placeholder
    // that bounces implies content the user could scroll to.
    return const ProfileStack(
      interactive: false,
      cards: [
        Center(child: SkeletonBox(width: 200, height: 36, radius: 28)),
        PeopleGroupHeroCardSkeleton(),
        DetailSectionCardSkeleton(rows: 4),
      ],
    );
  }
}

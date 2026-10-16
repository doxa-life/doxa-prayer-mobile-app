import 'package:doxa_prayer_mobile_app/components/widgets/people_groups_list.dart';
import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class PeopleGroupsScreen extends StatelessWidget {
  const PeopleGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Edge to edge, so the search bar's white band can reach the screen's
    // sides; the list pads its own content.
    return const PeopleGroupsList(
      listBottomPadding: AppSpacing.xxl,
      fullBleed: true,
    );
  }
}

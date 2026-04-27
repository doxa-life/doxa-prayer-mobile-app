import 'package:doxa_prayer_mobile_app/components/widgets/people_groups_list.dart';
import 'package:flutter/material.dart';

import '../layouts/page_scaffold.dart';

class PeopleGroupsScreen extends StatelessWidget {
  const PeopleGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(child: PeopleGroupsList());
  }
}

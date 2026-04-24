import 'package:doxa_prayer_mobile_app/components/nav/details_nav_bar.dart';
import 'package:flutter/material.dart';

class PeopleGroupDetailsScreen extends StatelessWidget {
  const PeopleGroupDetailsScreen({super.key, this.slug});

  final String? slug;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailsNavBar(
        title: 'People Group',
        onBack: () => Navigator.pop(context),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'People Group Details — stub\n\nWill show details from pray.doxa.life/api/people-groups/detail/{slug}.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PeopleGroupDetailsScreen extends StatelessWidget {
  const PeopleGroupDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('People Group')),
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

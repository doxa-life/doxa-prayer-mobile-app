import 'package:flutter/material.dart';

import 'people_group_details_screen.dart';

class PeopleGroupsScreen extends StatelessWidget {
  const PeopleGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'People Groups — stub\n\nWill list people groups from pray.doxa.life/api/peoplegroups/list with search and QR scan.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PeopleGroupDetailsScreen(),
                  ),
                );
              },
              child: const Text('View details (stub)'),
            ),
          ],
        ),
      ),
    );
  }
}

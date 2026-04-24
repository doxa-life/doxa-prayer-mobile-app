import 'package:flutter/material.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Reminders — stub\n\nWill let the user create multiple prayer reminders by day of week and time.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

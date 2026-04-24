import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Home — stub\n\nWill show the selected people group card and a summary of upcoming reminders.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

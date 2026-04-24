import 'package:flutter/material.dart';

class PrayScreen extends StatelessWidget {
  const PrayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          "Pray — stub\n\nWill render today's prayer content from pray.doxa.life and let the user log a prayer session.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

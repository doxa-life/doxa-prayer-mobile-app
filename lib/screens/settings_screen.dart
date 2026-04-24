import 'package:doxa_prayer_mobile_app/components/nav/details_nav_bar.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailsNavBar(
        title: 'Settings',
        onBack: () => Navigator.pop(context),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Settings — stub\n\nWill expose language selection, permission management, and the app version.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

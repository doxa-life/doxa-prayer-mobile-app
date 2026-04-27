import 'package:doxa_prayer_mobile_app/components/inputs/language_switcher.dart';
import 'package:doxa_prayer_mobile_app/components/nav/details_nav_bar.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailsNavBar(
        title: AppLocalizations.of(context)!.settings,
        onBack: () => Navigator.pop(context),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [LanguageSwitcher()],
          ),
        ),
      ),
    );
  }
}

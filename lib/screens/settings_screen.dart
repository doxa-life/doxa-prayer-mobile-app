import 'package:doxa_prayer_mobile_app/components/inputs/language_switcher.dart';
import 'package:doxa_prayer_mobile_app/components/nav/details_nav_bar.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: DetailsNavBar(
        title: l.settings,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          children: [
            const LanguageSwitcher(),
            const SizedBox(height: AppSpacing.xl),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.signUpForUpdates),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/news-signup'),
            ),
          ],
        ),
      ),
    );
  }
}

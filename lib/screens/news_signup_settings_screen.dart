import 'package:flutter/material.dart';

import '../components/nav/details_nav_bar.dart';
import '../components/widgets/news_signup.dart';
import '../l10n/app_localizations.dart';
import '../layouts/page_scaffold.dart';
import '../services/news_signup_service.dart';

class NewsSignupSettingsScreen extends StatelessWidget {
  const NewsSignupSettingsScreen({super.key});

  Future<void> _onSubmit(BuildContext context, NewsSignupData data) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context)!;
    await submitNewsSignup(data);
    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(l.newsSignupThanks)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: DetailsNavBar(
        title: l.signUpForUpdates,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: PageContainer(
          child: SingleChildScrollView(
            child: NewsSignup(onSubmit: (data) => _onSubmit(context, data)),
          ),
        ),
      ),
    );
  }
}

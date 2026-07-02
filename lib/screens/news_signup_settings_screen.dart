import 'package:flutter/material.dart';

import '../components/nav/details_nav_bar.dart';
import '../components/widgets/news_signup.dart';
import '../l10n/app_localizations.dart';
import '../layouts/page_scaffold.dart';
import '../services/news_signup_service.dart';

class NewsSignupSettingsScreen extends StatelessWidget {
  const NewsSignupSettingsScreen({super.key});

  // Errors propagate so NewsSignup surfaces them inline; on success the widget
  // shows its own in-place confirmation (thank-you + verify-your-email), so we
  // deliberately don't toast or pop here.
  Future<void> _onSubmit(NewsSignupData data) => submitNewsSignup(data);

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
            child: NewsSignup(onSubmit: _onSubmit),
          ),
        ),
      ),
    );
  }
}

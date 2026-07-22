import 'package:flutter/material.dart';

import '../components/nav/details_nav_bar.dart';
import '../components/widgets/feedback_form.dart';
import '../l10n/app_localizations.dart';
import '../layouts/page_scaffold.dart';

/// Full-screen feedback flyover, pushed on the root navigator so it covers the
/// tab shell (same pattern as the settings panel). Replaces the old external
/// browser hand-off with a native form that submits directly to the API.
class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: DetailsNavBar(
        title: l.feedback,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: PageContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const FeedbackForm(),
          ),
        ),
      ),
    );
  }
}

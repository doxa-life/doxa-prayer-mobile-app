import 'package:flutter/material.dart';

import '../components/nav/details_nav_bar.dart';
import '../components/nav/root_pop_scope.dart';
import '../components/notifications/enable_notifications_prompt.dart';
import '../components/widgets/news_signup.dart';
import '../l10n/app_localizations.dart';
import '../layouts/page_scaffold.dart';
import '../services/identity_service.dart';
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
    // Already-signed-up users (they have a profile) get the enable-notifications
    // prompt here too, so they can opt into push later without re-signing-up.
    // The prompt self-hides when notifications are already enabled.
    final alreadySignedUp = identityController.value?.profileId != null;
    return Scaffold(
      appBar: DetailsNavBar(
        title: l.signUpForUpdates,
        onBack: () => safeBack(context),
      ),
      body: SafeArea(
        child: PageContainer(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NewsSignup(onSubmit: _onSubmit),
                if (alreadySignedUp) const EnableNotificationsPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

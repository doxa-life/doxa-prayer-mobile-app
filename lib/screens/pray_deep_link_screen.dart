import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/buttons/action_button.dart';
import '../components/misc/background_image_container.dart';
import '../components/prayer_content/prayer_session_view.dart';
import '../l10n/app_localizations.dart';
import '../services/locale_controller.dart';
import '../services/referral_controller.dart';
import '../theme/app_spacing.dart';

/// Standalone Pray surface for a `/<slug>/prayer` deep link opened *before*
/// onboarding is complete. The visitor sees the prayer content for the group
/// they came for, then continues into the wizard — which auto-selects that
/// group via the referred-slug it stashes here. This keeps the deep link from
/// granting a pre-onboarding user free run of the tabbed app.
class PrayDeepLinkScreen extends StatelessWidget {
  const PrayDeepLinkScreen({super.key, required this.slug, this.date});

  final String slug;
  final DateTime? date;

  void _continue(BuildContext context) {
    setReferredPeopleGroup(slug);
    context.go('/wizard');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BackgroundImageContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ValueListenableBuilder<Locale>(
          valueListenable: localeController,
          builder: (context, locale, _) {
            return PrayerSessionView(
              key: ValueKey('$slug-${locale.languageCode}'),
              slug: slug,
              language: locale.languageCode,
              initialDate: date,
              isActive: () => true,
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ActionButton.fullWidth(
              label: l10n.continueLabel,
              onPressed: () => _continue(context),
            ),
          ),
        ),
      ),
    );
  }
}

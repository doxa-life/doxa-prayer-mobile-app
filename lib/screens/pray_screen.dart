import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/buttons/action_button.dart';
import '../components/misc/hyphenated_text.dart';
import '../components/prayer_content/people_group_avatar_row.dart';
import '../components/prayer_content/prayer_session_view.dart';
import '../l10n/app_localizations.dart';
import '../layouts/page_scaffold.dart';
import '../router.dart';
import '../services/locale_controller.dart';
import '../services/pray_override_controller.dart';
import '../services/subscribed_people_groups_controller.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class PrayScreen extends StatelessWidget {
  const PrayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // A deep-link override (`/<slug>/prayer`) takes precedence over the user's
    // own subscriptions for this visit; it is cleared when they leave the tab.
    return ValueListenableBuilder<PrayOverride?>(
      valueListenable: prayOverrideController,
      builder: (context, override, _) {
        return ValueListenableBuilder<SubscribedPeopleGroups>(
          valueListenable: peopleGroupsController,
          builder: (context, groups, _) {
            final slug = override?.slug ?? groups.active?.slug;
            if (slug == null) {
              return const PageContainer(child: _NoSubscriptionsView());
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hidden while a deep link is in charge: the row switches the
                // user's own groups, and the group on screen isn't one of them.
                if (override == null)
                  PageContainer(
                    bottomPadding: 0,
                    child: PeopleGroupAvatarRow(activeSlug: slug),
                  ),
                Expanded(
                  child: ValueListenableBuilder<Locale>(
                    valueListenable: localeController,
                    builder: (context, locale, _) {
                      return PrayerSessionView(
                        key: ValueKey('$slug-${locale.languageCode}'),
                        slug: slug,
                        language: locale.languageCode,
                        initialDate: override?.date,
                        isActive: _isOnPrayRoute,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static bool _isOnPrayRoute() =>
      appRouter.routerDelegate.currentConfiguration.uri.path == '/pray';
}

class _NoSubscriptionsView extends StatelessWidget {
  const _NoSubscriptionsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.xl,
        children: [
          HyphenatedText(
            l10n.noPeopleGroupSelected,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium,
          ),
          // Without this the empty state is a dead end: the Pray tab is where
          // someone with no subscriptions most plausibly lands.
          ActionButton(
            label: l10n.choosePeopleGroup,
            onPressed: () => context.go('/people-groups'),
            color: ActionButtonColor.secondary,
          ),
        ],
      ),
    );
  }
}

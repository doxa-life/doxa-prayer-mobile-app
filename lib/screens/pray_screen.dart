import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import '../services/pray_selector_controller.dart';
import '../services/subscribed_people_groups_controller.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class PrayScreen extends StatefulWidget {
  const PrayScreen({super.key});

  @override
  State<PrayScreen> createState() => _PrayScreenState();
}

class _PrayScreenState extends State<PrayScreen> {
  @override
  void initState() {
    super.initState();
    // Once, on the first arrival with something to switch between: show the
    // switcher so it is not a control nobody knows is there. Every arrival
    // after that opens on the prayer content.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (peopleGroupsController.value.list.length < 2) return;
      openPraySelectorIfUnseen();
    });
  }

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
                // Hidden while a deep link is in charge: the switcher moves
                // between the user's own groups, and the group on screen is
                // not one of them.
                if (override == null) _buildSelector(slug),
                Expanded(child: _buildContent(slug, override)),
              ],
            );
          },
        );
      },
    );
  }

  /// The switcher, which slides down from under the app bar and back up again.
  /// Collapsed it takes no height at all — the avatar in the app bar is what
  /// stands in for it.
  Widget _buildSelector(String slug) {
    return ValueListenableBuilder<bool>(
      valueListenable: praySelectorOpen,
      builder: (context, open, child) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          // Anchored to the top so the row slides up out of view rather than
          // shrinking towards its own middle.
          alignment: Alignment.topCenter,
          child: open
              ? child
              : const SizedBox(width: double.infinity, height: 0),
        );
      },
      child: PageContainer(
        bottomPadding: 0,
        child: PeopleGroupAvatarRow(activeSlug: slug),
      ),
    );
  }

  /// Reading is the signal that the user is done choosing: the first drag or
  /// the first touch on the content collapses the switcher.
  Widget _buildContent(String slug, PrayOverride? override) {
    return Listener(
      onPointerDown: (_) => closePraySelector(),
      child: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction != ScrollDirection.idle) {
            closePraySelector();
          }
          return false;
        },
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

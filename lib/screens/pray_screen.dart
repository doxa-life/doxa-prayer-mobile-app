import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/buttons/action_button.dart';
import '../components/misc/hyphenated_text.dart';
import '../components/prayer_content/pray_group_switcher.dart';
import '../components/prayer_content/prayer_session_view.dart';
import '../l10n/app_localizations.dart';
import '../layouts/page_scaffold.dart';
import '../router.dart';
import '../services/locale_controller.dart';
import '../services/pray_override_controller.dart';
import '../services/subscribed_people_groups_controller.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class PrayScreen extends StatefulWidget {
  const PrayScreen({super.key});

  @override
  State<PrayScreen> createState() => _PrayScreenState();
}

class _PrayScreenState extends State<PrayScreen> {
  /// How long the active group has to stay put, while the tab is out of view,
  /// before the tab rebuilds for it.
  static const Duration _offscreenSettle = Duration(milliseconds: 700);

  /// The group whose prayer is on the tab. Follows the active group straight
  /// away while the tab is in view; while it isn't, only once the active group
  /// has settled. Swiping through the home screen's cards changes the active
  /// group at the end of every swipe, and each change tears the prayer session
  /// down and builds the next one — on the very frames the home screen is
  /// still settling. Waiting builds once, for the group the user stopped on,
  /// after they have.
  String? _shownSlug;
  Timer? _settle;

  @override
  void initState() {
    super.initState();
    _shownSlug = peopleGroupsController.value.active?.slug;
    peopleGroupsController.addListener(_onGroupsChanged);
    appRouter.routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    _settle?.cancel();
    peopleGroupsController.removeListener(_onGroupsChanged);
    appRouter.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onGroupsChanged() {
    final slug = peopleGroupsController.value.active?.slug;
    _settle?.cancel();
    if (slug == _shownSlug) return;
    if (_isOnPrayRoute() || slug == null || _shownSlug == null) {
      _show(slug);
      return;
    }
    _settle = Timer(_offscreenSettle, () => _show(slug));
  }

  /// Arriving on the tab before the wait is up shows the right group anyway.
  void _onRouteChanged() {
    if (_settle?.isActive != true || !_isOnPrayRoute()) return;
    _settle!.cancel();
    _show(peopleGroupsController.value.active?.slug);
  }

  void _show(String? slug) {
    if (!mounted || slug == _shownSlug) return;
    setState(() => _shownSlug = slug);
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
            // The shown group, unless it has since been removed.
            final shown = groups.contains(_shownSlug ?? '')
                ? _shownSlug
                : groups.active?.slug;
            final slug = override?.slug ?? shown;
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

  /// The switcher between the user's groups, above the prayer — swiped like
  /// the home screen's carousel.
  Widget _buildSelector(String slug) => const PageContainer(
    verticalPadding: 0,
    horizontalPadding: 0,
    child: Padding(
      padding: EdgeInsets.only(top: AppSpacing.sm),
      child: PrayGroupSwitcher(),
    ),
  );

  Widget _buildContent(String slug, PrayOverride? override) {
    return ValueListenableBuilder<Locale>(
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

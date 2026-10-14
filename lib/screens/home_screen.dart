import 'package:doxa_prayer_mobile_app/components/buttons/cta_button.dart';
import 'package:doxa_prayer_mobile_app/components/cards/people_group_carousel.dart';
import 'package:doxa_prayer_mobile_app/components/cards/prayer_reminder_card.dart';
import 'package:doxa_prayer_mobile_app/components/cards/reminders_summary.dart';
import 'package:doxa_prayer_mobile_app/components/misc/app_icon.dart';
import 'package:doxa_prayer_mobile_app/components/misc/share_people_group_modal.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/layouts/page_scaffold.dart';
import 'package:doxa_prayer_mobile_app/router.dart';
import 'package:doxa_prayer_mobile_app/services/api_config.dart';
import 'package:doxa_prayer_mobile_app/services/map_config.dart';
import 'package:doxa_prayer_mobile_app/services/prayer_history_service.dart';
import 'package:doxa_prayer_mobile_app/services/prayer_reminder_controller.dart';
import 'package:doxa_prayer_mobile_app/services/reminders_controller.dart';
import 'package:doxa_prayer_mobile_app/services/subscribed_people_groups_controller.dart';
import 'package:doxa_prayer_mobile_app/theme/app_colors.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // A single ListView child wrapping this Column collapses every card's
    // loose (non-button) text into one merged semantics node — a screen reader
    // reads the whole page at once instead of stopping on each item. A
    // SingleChildScrollView keeps each element as its own accessibility stop.
    return SingleChildScrollView(
      child: PageContainer(
        child: Column(
          spacing: AppSpacing.xxl,
          children: [
            // The map button belongs with the people groups, so it sits closer
            // to them than to the reminders below.
            Column(
              spacing: AppSpacing.lg,
              children: [_peopleGroupsCardOrCTA(), const _ViewMapButton()],
            ),
            _reminderSection(),
          ],
        ),
      ),
    );
  }

  void _openDetails(String slug, BuildContext context) {
    context.push('/people-groups/$slug');
  }

  /// Praying for a group from its card also makes it the active group, so the
  /// Pray tab shows what the user just tapped rather than whatever it showed
  /// last.
  Future<void> _openPray(BuildContext context, String slug) async {
    await setActivePeopleGroup(slug);
    if (context.mounted) context.goNamed(AppRoute.pray.name);
  }

  Widget _peopleGroupsCardOrCTA() {
    return ValueListenableBuilder<SubscribedPeopleGroups>(
      valueListenable: peopleGroupsController,
      builder: (context, groups, _) {
        if (groups.isEmpty) {
          return CtaButton(
            label: AppLocalizations.of(context)!.selectPeopleGroup,
            onPressed: () => context.go('/people-groups'),
          );
        }
        return PeopleGroupCarousel(
          // Rebuilt from scratch when the set of groups changes, so the
          // scroll-to-active runs again for the new list.
          key: ValueKey(groups.list.map((g) => g.slug).join(',')),
          groups: groups.list,
          activeSlug: groups.active?.slug,
          onPray: (g) => _openPray(context, g.slug),
          onDetails: (g) => _openDetails(g.slug, context),
          onShare: (g) => _openShare(context, g),
          onMap: (g) => context.push('/people-groups/${g.slug}/map'),
          onAdd: () => context.go('/people-groups'),
        );
      },
    );
  }

  /// The deep link to install the app / pray for a people group — the same
  /// route the campaigns server profile pages link to.
  String _shareLink(String slug) => ApiConfig.buildUri('/app/$slug').toString();

  /// One share entry point: the modal shows the QR code for sharing in person
  /// and hands off to the device's share sheet for every other channel.
  void _openShare(BuildContext context, SubscribedPeopleGroup group) {
    showSharePeopleGroupModal(
      context,
      url: _shareLink(group.slug),
      peopleGroupName: group.name,
      onShareLink: (origin) => _share(context, group, origin),
    );
  }

  void _share(BuildContext context, SubscribedPeopleGroup group, Rect? origin) {
    final text =
        '${AppLocalizations.of(context)!.shareMessage(group.name)} '
        '${_shareLink(group.slug)}';

    SharePlus.instance.share(
      // iPads require a popover anchor; the modal reports where it was.
      ShareParams(text: text, sharePositionOrigin: origin),
    );
  }
}

/// Opens the map of every people group — the way onto the map that doesn't
/// depend on first picking one of the user's groups in the carousel, and the
/// only one for a user who hasn't picked any yet.
///
/// Outlined rather than filled so it never competes with the carousel's Pray
/// buttons or the select-a-group call to action above it.
class _ViewMapButton extends StatelessWidget {
  const _ViewMapButton();

  void _open(BuildContext context) {
    // A build with no Mapbox token says why rather than opening a map that can
    // only ever show grey squares — the same answer the carousel gives.
    if (!MapConfig.isConfigured) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.mapNotConfigured),
          ),
        );
      return;
    }
    context.push('/map');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _open(context),
        icon: const AppIcon(
          AppIconName.geoAlt,
          size: 20,
          color: AppColors.primary,
        ),
        // No explicit style: the theme's label style picks the right face for
        // the current language.
        label: Text(AppLocalizations.of(context)!.viewMap.toUpperCase()),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: AppColors.surface.withValues(alpha: 0.9),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// The reminder slot: a nudge to pray for the next people group that still
/// needs today's prayer, otherwise the usual "next reminder in…" card (or the
/// set-one-up CTA).
Widget _reminderSection() {
  return ListenableBuilder(
    listenable: Listenable.merge([
      peopleGroupsController,
      prayedTodayController,
      prayerReminderDismissedController,
    ]),
    builder: (context, _) {
      final needsPrayer = peopleGroupNeedingPrayer();
      return needsPrayer == null
          ? _remindersCardOrCTA()
          : PrayerReminderCard(group: needsPrayer);
    },
  );
}

Widget _remindersCardOrCTA() {
  return ValueListenableBuilder<Reminders?>(
    valueListenable: remindersController,
    builder: (context, reminders, _) {
      final hasAny = reminders != null && reminders.list.isNotEmpty;
      return hasAny
          ? RemindersSummary(reminders: reminders)
          : CtaButton(
              label: AppLocalizations.of(context)!.setReminder,
              leadingIcon: const AppIcon(AppIconName.bell),
              onPressed: () => context.push('/reminders'),
            );
    },
  );
}

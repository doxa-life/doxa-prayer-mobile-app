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
import 'package:doxa_prayer_mobile_app/services/prayer_history_service.dart';
import 'package:doxa_prayer_mobile_app/services/prayer_reminder_controller.dart';
import 'package:doxa_prayer_mobile_app/services/reminders_controller.dart';
import 'package:doxa_prayer_mobile_app/services/subscribed_people_groups_controller.dart';
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
          children: [_peopleGroupsCardOrCTA(), _reminderSection()],
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

/// The reminder slot: a nudge to pray today when the user has an active people
/// group they haven't prayed for yet and hasn't dismissed it this session,
/// otherwise the usual "next reminder in…" card (or the set-one-up CTA).
Widget _reminderSection() {
  return ListenableBuilder(
    listenable: Listenable.merge([
      peopleGroupsController,
      prayedTodayController,
      prayerReminderDismissedController,
    ]),
    builder: (context, _) {
      final active = activePeopleGroup;
      final nudge =
          active != null &&
          prayedTodayController.value.isEmpty &&
          !prayerReminderDismissedController.value;

      return nudge
          ? PrayerReminderCard(peopleGroupName: active.name)
          : _remindersCardOrCTA();
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
              onPressed: () => context.go('/reminders'),
            );
    },
  );
}

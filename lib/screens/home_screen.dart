import 'package:doxa_prayer_mobile_app/components/buttons/cta_button.dart';
import 'package:doxa_prayer_mobile_app/components/cards/get_involved_card.dart';
import 'package:doxa_prayer_mobile_app/components/cards/people_group_carousel.dart';
import 'package:doxa_prayer_mobile_app/components/cards/reminders_summary.dart';
import 'package:doxa_prayer_mobile_app/components/misc/app_icon.dart';
import 'package:doxa_prayer_mobile_app/components/misc/prayer_reminder_banner.dart';
import 'package:doxa_prayer_mobile_app/components/misc/qr_share_modal.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/layouts/page_scaffold.dart';
import 'package:doxa_prayer_mobile_app/router.dart';
import 'package:doxa_prayer_mobile_app/services/api_config.dart';
import 'package:doxa_prayer_mobile_app/services/reminders_controller.dart';
import 'package:doxa_prayer_mobile_app/services/subscribed_people_groups_controller.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const _donateUrl = 'https://giving.ag.org/donate/600001-6c2327';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // A single ListView child wrapping this Column collapses every card's
    // loose (non-button) text into one merged semantics node — a screen reader
    // reads the whole page at once instead of stopping on each item. A
    // SingleChildScrollView keeps each element as its own accessibility stop.
    return PrayerReminderBanner(
      child: SingleChildScrollView(
        child: PageContainer(
          child: Column(
            spacing: AppSpacing.xxl,
            children: [
              _peopleGroupsCardOrCTA(),
              _remindersCardOrCTA(),
              _getInvolvedCard(context),
            ],
          ),
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
          onShare: (g) => _share(context, g),
          onShowQr: (g) => showQrShareModal(
            context,
            url: _shareLink(g.slug),
            peopleGroupName: g.name,
          ),
          onAdd: () => context.go('/people-groups'),
        );
      },
    );
  }

  Widget _getInvolvedCard(BuildContext context) {
    return GetInvolvedCard(
      onDonate: () => _openExternalUrl(_donateUrl),
      onFeedback: () => context.push('/feedback'),
    );
  }

  void _openExternalUrl(String url) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  /// The deep link to install the app / pray for a people group — the same
  /// route the campaigns server profile pages link to.
  String _shareLink(String slug) => ApiConfig.buildUri('/app/$slug').toString();

  void _share(BuildContext context, SubscribedPeopleGroup group) {
    final text =
        '${AppLocalizations.of(context)!.shareMessage(group.name)} '
        '${_shareLink(group.slug)}';

    // iPads require a popover anchor; anchor the share sheet to the card.
    final box = context.findRenderObject() as RenderBox?;
    SharePlus.instance.share(
      ShareParams(
        text: text,
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }
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

import 'package:doxa_prayer_mobile_app/components/buttons/cta_button.dart';
import 'package:doxa_prayer_mobile_app/components/cards/get_involved_card.dart';
import 'package:doxa_prayer_mobile_app/components/cards/people_group_card.dart';
import 'package:doxa_prayer_mobile_app/components/cards/reminders_summary.dart';
import 'package:doxa_prayer_mobile_app/components/misc/app_icon.dart';
import 'package:doxa_prayer_mobile_app/components/misc/qr_share_modal.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/layouts/page_scaffold.dart';
import 'package:doxa_prayer_mobile_app/router.dart';
import 'package:doxa_prayer_mobile_app/services/api_config.dart';
import 'package:doxa_prayer_mobile_app/services/reminders_controller.dart';
import 'package:doxa_prayer_mobile_app/services/selected_people_group_controller.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const _donateUrl = 'https://giving.ag.org/donate/600001-6c2327';
const _feedbackUrl = 'https://doxa.life/feedback';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        PageContainer(
          child: Column(
            spacing: AppSpacing.xxl,
            children: [
              _peopleGroupCardOrCTA(),
              _remindersCardOrCTA(),
              _getInvolvedCard(),
            ],
          ),
        ),
      ],
    );
  }

  void _openDetails(String slug, BuildContext context) {
    context.push('/people-groups/$slug');
  }

  void _openPray(BuildContext context) {
    context.goNamed(AppRoute.pray.name);
  }

  Widget _peopleGroupCardOrCTA() {
    return ValueListenableBuilder<SelectedPeopleGroup?>(
      valueListenable: selectedPeopleGroupController,
      builder: (context, selected, _) {
        return selected == null
            ? CtaButton(
                label: AppLocalizations.of(context)!.selectPeopleGroup,
                onPressed: () => context.go('/people-groups'),
              )
            : PeopleGroupCard(
                name: selected.name,
                imageUrl: selected.imageUrl ?? '',
                onPray: () => _openPray(context),
                onDetails: () => _openDetails(selected.slug, context),
                onShare: () => _share(context, selected),
                onShowQr: () => showQrShareModal(
                  context,
                  url: _shareLink(selected.slug),
                  peopleGroupName: selected.name,
                ),
              );
      },
    );
  }

  Widget _getInvolvedCard() {
    return GetInvolvedCard(
      onDonate: () => _openExternalUrl(_donateUrl),
      onFeedback: () => _openExternalUrl(_feedbackUrl),
    );
  }

  void _openExternalUrl(String url) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  /// The deep link to install the app / pray for a people group — the same
  /// route the campaigns server profile pages link to.
  String _shareLink(String slug) => ApiConfig.buildUri('/app/$slug').toString();

  void _share(BuildContext context, SelectedPeopleGroup selected) {
    final text =
        '${AppLocalizations.of(context)!.shareMessage(selected.name)} '
        '${_shareLink(selected.slug)}';

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

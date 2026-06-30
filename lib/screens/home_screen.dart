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
import 'package:doxa_prayer_mobile_app/services/feedback_url.dart';
import 'package:doxa_prayer_mobile_app/services/identity_service.dart';
import 'package:doxa_prayer_mobile_app/services/locale_controller.dart';
import 'package:doxa_prayer_mobile_app/services/prayer_history_service.dart';
import 'package:doxa_prayer_mobile_app/services/reminders_controller.dart';
import 'package:doxa_prayer_mobile_app/services/selected_people_group_controller.dart';
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
        if (selected == null) {
          return CtaButton(
            label: AppLocalizations.of(context)!.selectPeopleGroup,
            onPressed: () => context.go('/people-groups'),
          );
        }
        return ValueListenableBuilder<Set<String>>(
          valueListenable: prayedTodayController,
          builder: (context, prayedSlugs, _) {
            return PeopleGroupCard(
              name: selected.name,
              imageUrl: selected.imageUrl ?? '',
              prayedToday: prayedSlugs.contains(selected.slug),
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
      },
    );
  }

  Widget _getInvolvedCard() {
    return GetInvolvedCard(
      onDonate: () => _openExternalUrl(_donateUrl),
      onFeedback: _openFeedback,
    );
  }

  void _openExternalUrl(String url) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  /// Opens the feedback form hosted on the campaigns server. The form lives on
  /// the same host as the API (`ApiConfig`), so this resolves to the right
  /// production/staging/dev host automatically. The app's locale picks the
  /// localized route (English is unprefixed; other locales are path-prefixed,
  /// matching the server's `prefix_except_default` i18n strategy), and the
  /// `tracking_id` links the feedback to the user's existing subscriber.
  void _openFeedback() {
    final route = feedbackRoute(
      localeController.value.languageCode,
      identityController.value?.trackingId,
    );
    final uri = ApiConfig.buildUri(route.path, route.query);
    launchUrl(uri, mode: LaunchMode.externalApplication);
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

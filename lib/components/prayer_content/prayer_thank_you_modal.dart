import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../services/pray_override_controller.dart';
import '../../services/prayer_history_service.dart';
import '../../services/subscribed_people_groups_controller.dart';
import '../../services/thank_you_verse_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../misc/app_icon.dart';
import '../misc/hyphenated_text.dart';

/// Shows a modal thanking the user for praying, with [verse] as the day's
/// encouragement. Shown after the user taps "Amen".
Future<void> showPrayerThankYouModal(
  BuildContext context, {
  ThankYouVerse? verse,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => PrayerThankYouModal(verse: verse),
  );
}

class PrayerThankYouModal extends StatelessWidget {
  const PrayerThankYouModal({super.key, this.verse});

  /// The verse to show. Null when the verse set could not be loaded, in which
  /// case the modal falls back to the title and the Home button alone.
  final ThankYouVerse? verse;

  /// The first subscribed group with no prayer recorded today, or null when
  /// there is none left — which is also the case for a single-group user, who
  /// has just prayed for their only one.
  SubscribedPeopleGroup? _nextUnprayed() {
    final prayed = prayedTodayController.value;
    for (final group in peopleGroupsController.value.list) {
      if (!prayed.contains(group.slug)) return group;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: SingleChildScrollView(
        // Scrolls when large accessibility font scales make the content
        // taller than the dialog; shrink-wraps otherwise.
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.primary),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Semantics(
              header: true,
              child: HyphenatedText(
                l10n.prayerThankYouTitle,
                style: AppTypography.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            if (verse != null) ...[
              const SizedBox(height: AppSpacing.lg),
              HyphenatedText(
                verse!.text,
                style: AppTypography.bodyMedium.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.primaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              HyphenatedText(
                verse!.reference,
                style: AppTypography.caption.copyWith(
                  color: AppColors.primaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            // Someone praying for several groups usually means to pray for all
            // of them today. Offering the next one here is the nudge; it stays
            // a choice, rather than the tab pulling them along.
            if (_nextUnprayed() case final next?) ...[
              ActionButton.fullWidth(
                label: l10n.prayForNextGroup(next.name),
                onPressed: () {
                  Navigator.of(context).pop();
                  // A deep-link override outranks the active group on this
                  // tab, so it has to go or the switch would do nothing.
                  clearPrayOverride();
                  setActivePeopleGroup(next.slug);
                },
                color: ActionButtonColor.secondary,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            ActionButton.fullWidth(
              label: l10n.home,
              icon: const AppIcon(AppIconName.home),
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/home');
              },
              // Quieter than the "pray for the next group" action above it,
              // which is the one worth taking while they are still here.
              color: _nextUnprayed() == null
                  ? ActionButtonColor.secondary
                  : ActionButtonColor.white,
            ),
          ],
        ),
      ),
    );
  }
}

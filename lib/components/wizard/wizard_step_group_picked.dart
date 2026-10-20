import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../layouts/page_scaffold.dart';
import '../../models/people_group.dart';
import '../../services/wizard_controller.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../cards/elevated_card.dart';
import '../inputs/population_range_field.dart';
import '../misc/app_image.dart';
import '../misc/country_flag.dart';
import '../misc/entrance_fade_slide.dart';
import '../misc/fit_to_page.dart';
import '../misc/hyphenated_text.dart';

const _cardDelay = Duration(milliseconds: 300);
const _choiceDelay = Duration(milliseconds: 600);

/// Shown after "Pick a group for me" so the user sees which group they got,
/// and can keep it or move on to the next one in priority order.
///
/// Always fits on one screen, so both choices are in view without scrolling:
/// the layout is kept compact, and [FitToPage] shrinks it evenly when it
/// still doesn't fit (a small phone, or large accessibility text).
class WizardStepGroupPicked extends StatelessWidget {
  const WizardStepGroupPicked({super.key, required this.controller});

  final WizardController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final group = controller.pickedGroup;
    if (group == null) return const SizedBox.shrink();
    final busy = controller.autoSelectingGroup;
    return PageContainer(
      child: Center(
        child: FitToPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.xl,
            children: [
              HyphenatedText(
                l.wizardGroupPickedTitle(group.name),
                style: AppTypography.h2,
                textAlign: TextAlign.center,
              ),
              EntranceFadeSlide(
                // Keyed so "Pick another group" plays the entrance again.
                key: ValueKey(group.slug),
                delay: _cardDelay,
                child: _GroupSummaryCard(group: group),
              ),
              EntranceFadeSlide(
                delay: _choiceDelay,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.md,
                  children: [
                    HyphenatedText(
                      l.wizardGroupPickedQuestion,
                      style: AppTypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    ActionButton.fullWidth(
                      label: l.wizardGroupPickedContinueButton,
                      onPressed: busy
                          ? null
                          : controller.continueWithPickedGroup,
                      color: ActionButtonColor.secondary,
                    ),
                    ActionButton.fullWidth(
                      label: l.wizardGroupPickedRerollButton,
                      onPressed: busy ? null : controller.rerollPickedGroup,
                      color: ActionButtonColor.white,
                      isOutlined: true,
                    ),
                    Visibility(
                      visible: busy,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Photo, then the facts the ranking used and a few for context — all from
/// the cached list, so no extra fetch.
class _GroupSummaryCard extends StatelessWidget {
  const _GroupSummaryCard({required this.group});

  final PeopleGroup group;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // Name and country beside the photo; the facts use the full card width
    // below it, which keeps the card short.
    return ElevatedAppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          Row(
            spacing: AppSpacing.md,
            children: [
              AppImage(
                url: group.imageUrl,
                size: 72,
                semanticLabel: group.name,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.xxs,
                  children: [
                    HyphenatedText(
                      group.name,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (group.countryLabel != null)
                      Row(
                        spacing: AppSpacing.xs,
                        children: [
                          Flexible(child: _Fact(value: group.countryLabel!)),
                          if (group.countryCode != null)
                            CountryFlag(code: group.countryCode!),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xxs,
            children: [
              if (group.primaryLanguageLabel != null)
                _Fact(
                  label: l.primaryLanguage,
                  value: group.primaryLanguageLabel!,
                ),
              if (group.religionLabel != null)
                _Fact(label: l.primaryReligion, value: group.religionLabel!),
              if (group.population != null)
                _Fact(
                  label: l.population,
                  value: PopulationRangeField.format(
                    group.population!.toDouble(),
                  ),
                ),
              _Fact(value: l.nPeoplePraying(group.peoplePraying)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({this.label, required this.value});

  final String? label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return HyphenatedText(
      label == null ? value : '$label: $value',
      style: AppTypography.bodySmall.copyWith(
        color: scheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }
}

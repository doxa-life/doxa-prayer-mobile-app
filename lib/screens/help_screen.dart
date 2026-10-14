import 'package:flutter/material.dart';

import '../components/cards/elevated_card.dart';
import '../components/help/glossary_text.dart';
import '../components/misc/hyphenated_text.dart';
import '../components/misc/titles.dart';
import '../l10n/app_localizations.dart';
import '../layouts/page_scaffold.dart';
import '../services/help_content.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// The Help tab: DOXA's mission, the FAQ and the glossary.
///
/// What each section says lives in the ARB files, and which entries exist in
/// `services/help_content.dart` — this screen only lays them out. The mission
/// and the FAQ answers are glossary-aware, so a term they mention links to its
/// definition just as it does on a people group's profile.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // A SingleChildScrollView rather than a ListView, so each card's lines
    // stay separate accessibility stops — see HomeScreen.
    return SingleChildScrollView(
      child: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.xxl,
          children: [
            _Card(
              title: l.helpMissionTitle,
              child: GlossaryText(
                helpMission(l),
                style: AppTypography.bodyMedium,
              ),
            ),
            _Card(
              title: l.helpFaqTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, entry) in helpFaq.indexed) ...[
                    if (i > 0) const Divider(height: 1),
                    _FaqTile(entry: entry),
                  ],
                ],
              ),
            ),
            _Card(
              title: l.helpGlossaryTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.lg,
                children: [
                  for (final entry in glossary) _GlossaryRow(entry: entry),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ElevatedAppCard(
      padding: AppSpacing.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          Semantics(header: true, child: H2(title)),
          child,
        ],
      ),
    );
  }
}

/// A question that opens to show its answer.
class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.entry});

  final HelpFaqEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Theme(
      // ExpansionTile draws dividers of its own when open; the list already
      // separates its entries.
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: AppSpacing.md),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.primary,
        title: HyphenatedText(
          entry.question(l),
          softWrap: true,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        children: [
          GlossaryText(entry.answer(l), style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}

class _GlossaryRow extends StatelessWidget {
  const _GlossaryRow({required this.entry});

  final GlossaryEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xxs,
        children: [
          HyphenatedText(
            entry.term(l),
            softWrap: true,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          HyphenatedText(
            entry.definition(l),
            softWrap: true,
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}

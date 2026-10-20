import 'dart:math' as math;

import 'package:doxa_prayer_mobile_app/components/buttons/icon_label_button.dart';
import 'package:doxa_prayer_mobile_app/components/buttons/subscribe_people_group_button.dart';
import 'package:doxa_prayer_mobile_app/components/cards/engagement_item.dart';
import 'package:doxa_prayer_mobile_app/components/cards/profile_cards.dart';
import 'package:doxa_prayer_mobile_app/components/misc/icon_circle.dart';
import 'package:doxa_prayer_mobile_app/layouts/page_scaffold.dart';
import 'package:doxa_prayer_mobile_app/components/misc/app_image.dart';
import 'package:doxa_prayer_mobile_app/components/misc/background_image_container.dart';
import 'package:doxa_prayer_mobile_app/components/misc/check_icon.dart';
import 'package:doxa_prayer_mobile_app/components/misc/cached_data_builder.dart';
import 'package:doxa_prayer_mobile_app/components/misc/close_icon.dart';
import 'package:doxa_prayer_mobile_app/components/misc/app_icon.dart';
import 'package:doxa_prayer_mobile_app/components/misc/country_flag.dart';
import 'package:doxa_prayer_mobile_app/components/misc/engagement_status_pill.dart';
import 'package:doxa_prayer_mobile_app/components/misc/credit_popover_button.dart';
import 'package:doxa_prayer_mobile_app/components/nav/sheet_header.dart';
import 'package:doxa_prayer_mobile_app/components/nav/root_pop_scope.dart';
import 'package:doxa_prayer_mobile_app/components/widgets/people_group_details_skeleton.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/models/people_group_detail.dart';
import 'package:doxa_prayer_mobile_app/models/prayer_commitment.dart';
import 'package:doxa_prayer_mobile_app/services/locale_controller.dart';
import 'package:doxa_prayer_mobile_app/services/map_config.dart';
import 'package:doxa_prayer_mobile_app/services/people_group_locations.dart';
import 'package:doxa_prayer_mobile_app/services/people_groups_service.dart';
import 'package:doxa_prayer_mobile_app/theme/app_colors.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/misc/glossary_text.dart';
import '../components/misc/hyphenated_text.dart';

class PeopleGroupDetailsScreen extends StatefulWidget {
  const PeopleGroupDetailsScreen({
    super.key,
    this.slug,
    this.fromWizard = false,
  });

  final String? slug;

  /// When true, the screen was opened from the wizard's people-groups list.
  /// A successful selection via the "Select" button will pop with `true` so
  /// the wizard can advance past the confirm step.
  final bool fromWizard;

  @override
  State<PeopleGroupDetailsScreen> createState() =>
      _PeopleGroupDetailsScreenState();
}

class _PeopleGroupDetailsScreenState extends State<PeopleGroupDetailsScreen> {
  Future<PeopleGroupDetail> _load({bool forceRefresh = false}) {
    final slug = widget.slug;
    if (slug == null || slug.isEmpty) {
      return Future.error('Missing people group slug');
    }
    return fetchPeopleGroupDetail(
      slug,
      lang: localeController.value.languageCode,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return BackgroundImageContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: SheetHeader(onClose: () => safeBack(context)),
        // The page of cards runs from the header to the bottom edge; the space
        // around the cards is the page's own, so the loading skeleton (the
        // same page) takes exactly the same place.
        body: SafeArea(
          bottom: false,
          child: PageContainer(
            verticalPadding: 0,
            horizontalPadding: 0,
            child: CachedDataBuilder<PeopleGroupDetail>(
              cacheKey: peopleGroupDetailCacheKey(
                widget.slug ?? '',
                localeController.value.languageCode,
              ),
              fetch: _load,
              loading: (context) => const PeopleGroupDetailsSkeleton(),
              error: (context, retry) => _ErrorView(
                message: l.couldNotLoadPeopleGroupDetailsMessage,
                onRetry: retry,
              ),
              builder: (context, detail) =>
                  _DetailBody(detail: detail, fromWizard: widget.fromWizard),
            ),
          ),
        ),
      ),
    );
  }
}

/// The profile, as a page of cards: who the group is; what it is like and the
/// facts about it; how much prayer it has; how engaged it is; and the
/// resources in its language.
class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail, required this.fromWizard});

  final PeopleGroupDetail detail;
  final bool fromWizard;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final description = detail.raw['imb_people_description'];
    final cards = <Widget>[
      _Hero(
        detail: detail,
        action: SubscribePeopleGroupButton(
          slug: detail.slug,
          name: detail.name,
          imageUrl: detail.imageUrl,
          onAdded: fromWizard
              ? () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop(true);
                  }
                }
              : null,
        ),
      ),
      _ProfileSection(
        title: l.overview,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.lg,
          // A row with no value is left out altogether, rather than drawing
          // nothing and still taking the column's spacing — an uneven gap
          // where it sits (between Country and Population when there is no
          // alternate name).
          children: [
            // What the group is like leads the card, above the facts.
            if (description is String && description.trim().isNotEmpty) ...[
              GlossaryText(description, style: _descriptionStyle),
              ProfileHeadingRule(
                color: AppColors.white.withValues(alpha: 0.35),
              ),
            ],
            for (final row in <_DetailRow>[
              _DetailRow(
                label: l.status,
                value: _label(detail.raw['engagement_status']),
              ),
              _DetailRow(
                label: l.country,
                value: _label(detail.raw['country_code']),
                flagCodes: [?_value(detail.raw['country_code'])],
              ),
              _DetailRow(
                label: l.alternateName,
                value: detail.raw['imb_alternate_name']?.toString(),
              ),
              _DetailRow(
                label: l.population,
                value: _formatInt(detail.raw['population']),
              ),
              _DetailRow(
                label: l.primaryLanguage,
                value: _label(detail.raw['primary_language']),
              ),
              _DetailRow(
                label: l.primaryReligion,
                value: _label(detail.raw['religion']),
              ),
              _DetailRow(
                label: l.religiousPractices,
                value: detail.raw['religion'] is Map<String, dynamic>
                    ? (detail.raw['religion']
                              as Map<String, dynamic>)['description']
                          as String?
                    : null,
              ),
            ])
              if (row.isVisible) row,
          ],
        ),
      ),
      _CommittedProgress(
        committed: detail.peopleCommitted,
        groupName: detail.name,
      ),
      _ProfileSection(
        title: l.engagementStatus,
        child: _StatusGrid(
          children: [
            _StatusTile(
              label: l.prayerStatus,
              status: switch (prayerCommitmentLevelFor(
                detail.peopleCommitted,
              )) {
                PrayerCommitmentLevel.met => EngagementStatus.yes,
                PrayerCommitmentLevel.some => EngagementStatus.partial,
                PrayerCommitmentLevel.none => EngagementStatus.no,
              },
            ),
            _StatusTile(
              label: l.adoptionStatus,
              status: _yesNo(
                detail.raw['adopted_by_churches'] is num &&
                    (detail.raw['adopted_by_churches'] as num) > 0,
              ),
            ),
            // When the group is marked as engaged, the last three markers are
            // collapsed into a single "Engaged" marker.
            if (_isEngaged(detail))
              _StatusTile(label: l.engaged, status: EngagementStatus.yes)
            else ...[
              _StatusTile(
                label: l.crossCulturalWorkersPresent,
                status: _yesNo(detail.raw['workers_long_term'] == true),
              ),
              _StatusTile(
                label: l.workInLocalLanguageAndCulture,
                status: _yesNo(detail.raw['work_in_local_language'] == true),
              ),
              _StatusTile(
                label: l.discipleAndChurchMultiplication,
                status: _yesNo(
                  detail.raw['disciple_and_church_multiplication'] == true,
                ),
              ),
            ],
          ],
        ),
      ),
      _ProfileSection(
        title: l.resources,
        child: _StatusGrid(
          children: [
            // Left out when the API doesn't say either way.
            for (final (label, field) in [
              (l.bibleTranslation, 'imb_bible_available'),
              (l.bibleStories, 'imb_bible_stories_available'),
              (l.jesusFilm, 'imb_jesus_film_available'),
              (l.radioBroadcast, 'imb_radio_broadcast_available'),
              (l.gospelRecordings, 'imb_gospel_recordings_available'),
              (l.audioScripture, 'imb_audio_scripture_available'),
            ])
              if (detail.raw[field] is bool)
                _StatusTile(
                  label: label,
                  status: _yesNo(detail.raw[field] as bool),
                ),
          ],
        ),
      ),
    ];
    return ProfileStack(cards: cards);
  }
}

/// The first card: the group's name, large, with where it lives and how it
/// stands under it; then its photo, and under that the button to select it.
class _Hero extends StatelessWidget {
  const _Hero({required this.detail, required this.action});

  final PeopleGroupDetail detail;
  final Widget action;

  /// The widest the photo is drawn. Most photos are portrait, so on a tablet
  /// a full-width one would run taller than the screen.
  static const double maxImageWidth = 480;

  /// The group's name: the display face its name is set in on the home
  /// screen's cards, at the size of the profile's card headings.
  static final TextStyle nameStyle = AppTypography.h1.copyWith(
    fontSize: AppTypography.xxl * 1.2,
    height: 1.05,
  );

  @override
  Widget build(BuildContext context) {
    final credit = detail.pictureCredit;
    return ProfileCard(
      padding: AppSpacing.lg,
      // The map button sits over the card's corner rather than beside the
      // name, so nothing else on the card moves or narrows for it.
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: HyphenatedText(
                  detail.name,
                  textAlign: TextAlign.center,
                  style: nameStyle,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _HeroFacts(detail: detail),
              const SizedBox(height: AppSpacing.lg),
              // At the photo's own proportions — never cropped or stretched.
              LayoutBuilder(
                builder: (context, box) => Center(
                  child: Stack(
                    children: [
                      AppImage.naturalAspect(
                        url: detail.imageUrl,
                        size: math.min(box.maxWidth, maxImageWidth),
                        semanticLabel: detail.name,
                      ),
                      if (credit.isNotEmpty)
                        PositionedDirectional(
                          end: AppSpacing.md,
                          bottom: AppSpacing.md,
                          child: CreditPopoverButton(credit: credit),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              action,
            ],
          ),
          PositionedDirectional(
            top: 0,
            end: 0,
            child: _ViewOnMapButton(slug: detail.slug),
          ),
        ],
      ),
    );
  }
}

/// Opens the map with this group alone on it. Sits in the top corner of the
/// profile's first card.
///
/// A build with no Mapbox token says why the map can't open, as the home
/// screen's map button does. A group known to have no location leaves the
/// button muted and saying so.
class _ViewOnMapButton extends StatelessWidget {
  const _ViewOnMapButton({required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ValueListenableBuilder<Set<String>?>(
      valueListenable: peopleGroupSlugsWithLocation,
      builder: (context, located, _) {
        final hasLocation = mayHaveLocation(slug, located);
        return IconLabelButton(
          icon: const AppIcon(AppIconName.geoAlt),
          label: hasLocation ? l.viewOnMap : l.locationNotAvailable,
          onPressed: !MapConfig.isConfigured
              ? () => _showMapNotConfigured(context)
              : hasLocation
              ? () => context.push('/people-groups/$slug/map')
              : null,
        );
      },
    );
  }

  static void _showMapNotConfigured(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.mapNotConfigured)),
      );
  }
}

/// The group's description, at the top of the overview card.
final TextStyle _descriptionStyle = AppTypography.bodyLarge.copyWith(
  color: AppColors.white,
  fontSize: AppTypography.md,
  fontWeight: FontWeight.w500,
  height: 1.45,
);

/// Under the group's name: its country, with the flag, and the region it
/// lives in; then whether it is engaged and how many are praying for it —
/// what the browse list shows for each group.
class _HeroFacts extends StatelessWidget {
  const _HeroFacts({required this.detail});

  final PeopleGroupDetail detail;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final muted = AppColors.onSurface.withValues(alpha: 0.7);
    final country = _label(detail.raw['country_code']);
    final countryCode = _value(detail.raw['country_code']);
    final region = _label(detail.raw['region']);
    final hasStatus = _label(detail.raw['engagement_status']) != null;
    final praying = detail.peoplePraying;
    final prayingColor = praying > 0 ? AppColors.secondary : muted;
    return Column(
      spacing: AppSpacing.xs,
      children: [
        if (country != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.xs,
            children: [
              if (countryCode != null)
                CountryFlag(code: countryCode, height: 18),
              Flexible(
                child: HyphenatedText(
                  country,
                  textAlign: TextAlign.center,
                  style: AppTypography.titleMedium,
                ),
              ),
            ],
          ),
        if (region != null)
          HyphenatedText(
            region,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: muted),
          ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: [
            if (hasStatus) EngagementStatusPill(engaged: _isEngaged(detail)),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.xxs,
              children: [
                AppIcon(AppIconName.pray, size: 16, color: prayingColor),
                Flexible(
                  child: HyphenatedText(
                    l.nPeoplePraying(praying),
                    style: AppTypography.caption.copyWith(
                      color: prayingColor,
                      fontWeight: praying > 0
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// The heading of a dark green profile card: its title, large, and an
/// optional line under it saying what the card shows. Every card after the
/// first uses this, so they all head alike.
class _CardHeading extends StatelessWidget {
  const _CardHeading({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  static final TextStyle titleStyle = AppTypography.h1.copyWith(
    color: AppColors.white,
    fontSize: AppTypography.xxl * 1.2,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.xs,
      children: [
        Semantics(
          header: true,
          child: HyphenatedText(
            title,
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
        ),
        if (subtitle != null)
          HyphenatedText(
            subtitle!,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: _kMutedOnDark),
          ),
      ],
    );
  }
}

/// Secondary text on the dark green cards.
final Color _kMutedOnDark = AppColors.white.withValues(alpha: 0.75);

/// A dark green profile card under a [_CardHeading].
class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    this.subtitle,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      color: AppColors.primary,
      padding: AppSpacing.xl,
      header: _CardHeading(title: title, subtitle: subtitle),
      ruleColor: AppColors.white.withValues(alpha: 0.35),
      child: child,
    );
  }
}

class _CommittedProgress extends StatelessWidget {
  const _CommittedProgress({required this.committed, required this.groupName});

  final int committed;
  final String groupName;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context)!;
    final clamped = committed.clamp(0, kPeopleCommittedGoal);
    final ratio = kPeopleCommittedGoal == 0
        ? 0.0
        : clamped / kPeopleCommittedGoal;
    return _ProfileSection(
      title: l.prayerStatus,
      subtitle: l.prayerStatusExplanation(groupName),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: AppSpacing.md,
        children: [
          HyphenatedText(
            '$committed',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: AppTypography.xxl,
            ),
          ),
          HyphenatedText(
            l.committedToPrayFor(groupName),
            style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
          // The indicator's own semantics node takes the progress-bar role,
          // which only accepts a bare number for its value (read out as a
          // percentage of 0-100). Hiding that node and supplying our own lets
          // the bar announce the count it draws against the goal. The label is
          // what makes it a stop while swiping: a node carrying only a value
          // has no text for the screen reader to focus on, so it gets skipped.
          Semantics(
            container: true,
            label: l.dailyPrayerCoverage,
            value: '$clamped/$kPeopleCommittedGoal',
            child: ExcludeSemantics(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: AppTypography.md,
                  backgroundColor: AppColors.mutedSurface,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.secondary,
                  ),
                ),
              ),
            ),
          ),
          // The bar above already announces this caption as its label, so the
          // visible copy is hidden to keep it from being read out twice.
          ExcludeSemantics(
            child: HyphenatedText(
              l.dailyPrayerCoverage,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status tiles in a grid: two to a row on a phone, three where there is room.
class _StatusGrid extends StatelessWidget {
  const _StatusGrid({required this.children});

  final List<Widget> children;

  static const double _gap = AppSpacing.lg;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 3 : 2;
        final width = (constraints.maxWidth - _gap * (columns - 1)) / columns;
        return Wrap(
          spacing: _gap,
          runSpacing: AppSpacing.xl,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

/// One status in a [_StatusGrid]: a tick, part-tick or cross in a coloured
/// circle — smaller than the card's heading — its [label], and, when given,
/// an [explanation] of what it means.
class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.label,
    required this.status,
    // Left for the explanations to come.
    // ignore: unused_element_parameter
    this.explanation,
  });

  final String label;
  final EngagementStatus status;

  /// What this status means, under the label. Optional; none are written yet.
  final String? explanation;

  /// The tick or cross. Its circle adds [AppSpacing.xs] each side, which keeps
  /// it well under the height of the card's heading text.
  static const double _iconSize = AppTypography.lg;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final color = switch (status) {
      EngagementStatus.yes => AppColors.secondary,
      EngagementStatus.no => AppColors.scheme.error,
      EngagementStatus.partial => AppColors.partial,
    };
    final icon = status == EngagementStatus.no
        ? const CloseIcon(size: _iconSize, color: AppColors.white)
        : const CheckIcon(size: _iconSize, color: AppColors.white);
    final statusLabel = switch (status) {
      EngagementStatus.yes => l.yes,
      EngagementStatus.no => l.no,
      EngagementStatus.partial => l.partial,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        // The tick / cross is a text-less painted icon, so it carries the
        // spoken status as its own semantics node — kept apart from the
        // label, as a bare "No" at the end of a longer phrase was read by
        // TTS as "number".
        Semantics(
          label: statusLabel,
          child: IconCircle(icon: icon, color: color),
        ),
        // Glossary-aware: a marker such as "Engaged" links to its definition
        // when the glossary has one.
        GlossaryText(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (explanation != null)
          HyphenatedText(
            explanation!,
            style: AppTypography.bodySmall.copyWith(color: _kMutedOnDark),
          ),
      ],
    );
  }
}

/// One fact in the overview: its [label] above its [value], led by the flags
/// of [flagCodes] when it is about a place, and, when given, an [explanation]
/// of what it means.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.flagCodes = const [],
    // Left for the explanations to come.
    // ignore: unused_element_parameter
    this.explanation,
  });

  final String label;
  final String? value;

  /// ISO alpha-3 codes of the flags shown before the value.
  final List<String> flagCodes;

  /// What this fact means, under the value. Optional; none are written yet.
  final String? explanation;

  bool get isVisible => value != null && value!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.xxs,
      children: [
        HyphenatedText(
          label,
          style: AppTypography.bodySmall.copyWith(color: _kMutedOnDark),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: AppSpacing.xs,
          children: [
            for (final code in flagCodes) CountryFlag(code: code, height: 16),
            // Glossary-aware, so a value such as "Unengaged" links to what it
            // means.
            Expanded(
              child: GlossaryText(
                value!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (explanation != null)
          HyphenatedText(
            explanation!,
            style: AppTypography.bodySmall.copyWith(color: _kMutedOnDark),
          ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HyphenatedText(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: onRetry,
              child: HyphenatedText(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }
}

/// Whether the people group is marked as engaged, mirroring the doxa.life
/// people group details page (engagement_status value == "engaged").
bool _isEngaged(PeopleGroupDetail detail) {
  final status = detail.raw['engagement_status'];
  final value = status is Map<String, dynamic> ? status['value'] : status;
  return value?.toString().toLowerCase() == 'engaged';
}

String? _label(dynamic field) {
  if (field is Map<String, dynamic>) {
    final label = field['label'];
    if (label is String && label.isNotEmpty) return label;
    final value = field['value'];
    if (value is String && value.isNotEmpty) return value;
    return null;
  }
  if (field is String) return field;
  return null;
}

String? _value(dynamic field) {
  if (field is Map<String, dynamic>) {
    final value = field['value'];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

EngagementStatus _yesNo(bool yes) =>
    yes ? EngagementStatus.yes : EngagementStatus.no;

String? _formatInt(dynamic value) {
  if (value == null) return null;
  if (value is num) {
    final n = value.toInt();
    return n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
  return value.toString();
}

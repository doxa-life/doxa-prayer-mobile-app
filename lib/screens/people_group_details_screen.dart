import 'package:doxa_prayer_mobile_app/components/buttons/subscribe_people_group_button.dart';
import 'package:doxa_prayer_mobile_app/components/cards/engagement_item.dart';
import 'package:doxa_prayer_mobile_app/components/cards/profile_deck.dart';
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
import 'package:doxa_prayer_mobile_app/services/people_groups_service.dart';
import 'package:doxa_prayer_mobile_app/theme/app_colors.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:flutter/material.dart';

import '../components/help/glossary_text.dart';
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
        // The deck runs from the header to the bottom edge and from side to
        // side, with the cards either side showing at the edges; the space around
        // the cards is the deck's own, so the loading skeleton (the same deck)
        // takes exactly the same place.
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

/// The profile, as a deck of cards: who the group is, how much prayer it
/// has, how engaged it is, the overview, and the resources in its language.
class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail, required this.fromWizard});

  final PeopleGroupDetail detail;
  final bool fromWizard;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
      _CommittedProgress(
        committed: detail.peopleCommitted,
        groupName: detail.name,
      ),
      _DeckSection(
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
      _DeckSection(
        title: l.overview,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.lg,
          // A row with no value is left out altogether, rather than drawing
          // nothing and still taking the column's spacing — an uneven gap
          // where it sits (between Country and Population when there is no
          // alternate name).
          children: [
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
      _DeckSection(
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
    return ProfileDeck(
      cards: cards,
      // Every card after the first is dark green.
      darkCards: {for (var i = 1; i < cards.length; i++) i},
    );
  }
}

/// The first card: the group's name, large, with where it lives and how it
/// stands under it; its photo as the card's centrepiece — as large as the
/// card allows — then the button to add or remove it, and what the group is
/// like.
class _Hero extends StatelessWidget {
  const _Hero({required this.detail, required this.action});

  final PeopleGroupDetail detail;
  final Widget action;

  /// The most of the card's height the description takes before it scrolls,
  /// so a long one never squeezes the photo out.
  static const double descriptionShare = 0.3;

  /// On a phone the card is short, so the description gets more of it — the
  /// photo, in its `Expanded`, gives up the difference.
  static const double phoneDescriptionShare = 0.4;

  /// The description's sizes, largest first: it is set in the largest that
  /// fits its space without scrolling, down to the last.
  static const List<double> descriptionSizes = [
    AppTypography.lg,
    AppTypography.md,
    AppTypography.sm,
  ];

  static final TextStyle descriptionStyle = AppTypography.bodyLarge.copyWith(
    fontWeight: FontWeight.w500,
    height: 1.45,
  );

  static bool _isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide < 600;

  /// The largest of [descriptionSizes] at which [text] laid out at [width]
  /// fits in [maxHeight], or the smallest when none does.
  static TextStyle _fitDescription(
    BuildContext context,
    String text, {
    required double width,
    required double maxHeight,
  }) {
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    for (final size in descriptionSizes) {
      final style = descriptionStyle.copyWith(fontSize: size);
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: direction,
        textScaler: scaler,
      )..layout(maxWidth: width);
      final fits = painter.height <= maxHeight;
      painter.dispose();
      if (fits) return style;
    }
    return descriptionStyle.copyWith(fontSize: descriptionSizes.last);
  }

  /// How much of the card's width the photo fills.
  static const double imageShare = 0.88;

  /// The share of the card's height left clear at its foot, so the photo,
  /// button and description sit up under the facts rather than at the bottom.
  static const double footShare = 0.05;

  /// The group's name: the display face its name is set in on the home
  /// screen's cards, at the size of the profile's card headings.
  static final TextStyle nameStyle = AppTypography.h1.copyWith(
    fontSize: AppTypography.xxl * 1.2,
    height: 1.05,
  );

  @override
  Widget build(BuildContext context) {
    final credit = detail.pictureCredit;
    final description = detail.raw['imb_people_description'];
    return ProfileDeckCard(
      padding: AppSpacing.xl,
      fill: true,
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
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
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: LayoutBuilder(
                // The photo takes the full height of its space, so its top
                // sits just under the facts, with no gap above it.
                builder: (context, box) => Align(
                  alignment: Alignment.topCenter,
                  child: Stack(
                    children: [
                      AppImage(
                        url: detail.imageUrl,
                        size: box.maxWidth * imageShare,
                        height: box.maxHeight,
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
            ),
            const SizedBox(height: AppSpacing.lg),
            action,
            if (description is String) ...[
              const SizedBox(height: AppSpacing.lg),
              Builder(
                builder: (context) {
                  final maxHeight =
                      constraints.maxHeight *
                      (_isPhone(context)
                          ? phoneDescriptionShare
                          : descriptionShare);
                  return ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxHeight),
                    // Still scrolls if even the smallest size overflows, so
                    // nothing is ever cut off.
                    child: ProfileCardScroll(
                      child: GlossaryText(
                        description,
                        style: _fitDescription(
                          context,
                          description,
                          width: constraints.maxWidth,
                          maxHeight: maxHeight,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
            SizedBox(height: constraints.maxHeight * footShare),
          ],
        ),
      ),
    );
  }
}

/// Under the group's name: its country, with the flag, and the wider people
/// it belongs to; then whether it is engaged and how many are praying for it —
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
    final cluster = _label(detail.raw['rop1']);
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
        if (cluster != null)
          HyphenatedText(
            cluster,
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
class _DeckSection extends StatelessWidget {
  const _DeckSection({
    required this.title,
    this.subtitle,
    required this.child,
    this.bodyAlignment = Alignment.topCenter,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final AlignmentGeometry bodyAlignment;

  @override
  Widget build(BuildContext context) {
    return ProfileDeckCard(
      color: AppColors.primary,
      padding: AppSpacing.xl,
      header: _CardHeading(title: title, subtitle: subtitle),
      ruleColor: AppColors.white.withValues(alpha: 0.35),
      bodyAlignment: bodyAlignment,
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
    return _DeckSection(
      title: l.prayerStatus,
      subtitle: l.prayerStatusExplanation(groupName),
      bodyAlignment: Alignment.center,
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
            l.peopleCommittedToPraying,
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

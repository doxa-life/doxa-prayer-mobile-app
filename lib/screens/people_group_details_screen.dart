import 'package:doxa_prayer_mobile_app/components/buttons/select_people_group_button.dart';
import 'package:doxa_prayer_mobile_app/components/cards/elevated_card.dart';
import 'package:doxa_prayer_mobile_app/components/cards/engagement_item.dart';
import 'package:doxa_prayer_mobile_app/components/misc/icon_circle.dart';
import 'package:doxa_prayer_mobile_app/layouts/page_scaffold.dart';
import 'package:doxa_prayer_mobile_app/components/misc/app_image.dart';
import 'package:doxa_prayer_mobile_app/components/misc/background_image_container.dart';
import 'package:doxa_prayer_mobile_app/components/misc/check_icon.dart';
import 'package:doxa_prayer_mobile_app/components/misc/close_icon.dart';
import 'package:doxa_prayer_mobile_app/components/misc/credit_popover_button.dart';
import 'package:doxa_prayer_mobile_app/components/misc/titles.dart';
import 'package:doxa_prayer_mobile_app/components/nav/details_nav_bar.dart';
import 'package:doxa_prayer_mobile_app/components/nav/root_pop_scope.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/models/people_group_detail.dart';
import 'package:doxa_prayer_mobile_app/services/locale_controller.dart';
import 'package:doxa_prayer_mobile_app/services/people_groups_service.dart';
import 'package:doxa_prayer_mobile_app/theme/app_colors.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:flutter/material.dart';

const int _peopleCommittedGoal = 144;

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
  late Future<PeopleGroupDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<PeopleGroupDetail> _load() {
    final slug = widget.slug;
    if (slug == null || slug.isEmpty) {
      return Future.error('Missing people group slug');
    }
    return fetchPeopleGroupDetail(
      slug,
      lang: localeController.value.languageCode,
    );
  }

  void _reload() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return BackgroundImageContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: DetailsNavBar(
          title: l.peopleGroup,
          onBack: () => safeBack(context),
        ),
        body: SafeArea(
          child: PageContainer(
            child: FutureBuilder<PeopleGroupDetail>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _ErrorView(
                    message: l.couldNotLoadPeopleGroupDetailsMessage,
                    onRetry: _reload,
                  );
                }
                final detail = snapshot.data!;
                return _DetailBody(
                  detail: detail,
                  fromWizard: widget.fromWizard,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail, required this.fromWizard});

  final PeopleGroupDetail detail;
  final bool fromWizard;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.xl,
        children: [
          SelectPeopleGroupButton(
            slug: detail.slug,
            name: detail.name,
            imageUrl: detail.imageUrl,
            onConfirmed: fromWizard
                ? () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop(true);
                    }
                  }
                : null,
          ),
          _Hero(detail: detail),
          _CommittedProgress(committed: detail.peopleCommitted),
          ElevatedAppCard(
            padding: AppSpacing.xl,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                H2(l.engagementStatus),
                Wrap(
                  spacing: AppSpacing.xl,
                  runSpacing: AppSpacing.xl,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    EngagementItem(
                      label: l.prayerStatus,
                      status: detail.peopleCommitted >= _peopleCommittedGoal
                          ? EngagementStatus.yes
                          : detail.peopleCommitted > 0
                          ? EngagementStatus.partial
                          : EngagementStatus.no,
                    ),
                    EngagementItem(
                      label: l.adoptionStatus,
                      status: detail.raw['adopted_by_churches'] > 0
                          ? EngagementStatus.yes
                          : EngagementStatus.no,
                    ),
                    // When the group is marked as engaged, the last three
                    // markers are collapsed into a single "Engaged" marker.
                    if (_isEngaged(detail))
                      EngagementItem(
                        label: l.engaged,
                        status: EngagementStatus.yes,
                      )
                    else ...[
                      EngagementItem(
                        label: l.crossCulturalWorkersPresent,
                        status: detail.raw['workers_long_term'] != null
                            ? EngagementStatus.yes
                            : EngagementStatus.no,
                      ),
                      EngagementItem(
                        label: l.workInLocalLanguageAndCulture,
                        status: detail.raw['work_in_local_language'] != null
                            ? EngagementStatus.yes
                            : EngagementStatus.no,
                      ),
                      EngagementItem(
                        label: l.discipleAndChurchMultiplication,
                        status:
                            detail.raw['disciple_and_church_multiplication'] !=
                                null
                            ? EngagementStatus.yes
                            : EngagementStatus.no,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          _Section(
            title: l.overview,
            children: [
              _DetailRow(
                label: l.status,
                value: _label(detail.raw['engagement_status']),
              ),
              _DetailRow(
                label: l.country,
                value: detail.raw['country_code']?['label'],
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
              if (detail.raw['religion'] is Map<String, dynamic> &&
                  (detail.raw['religion']
                          as Map<String, dynamic>)['description']
                      is String)
                _DetailRow(
                  label: l.religiousPractices,
                  value:
                      (detail.raw['religion']
                              as Map<String, dynamic>)['description']
                          as String,
                ),
            ],
          ),
          _Section(
            title: l.resources,
            children: [
              _DetailRow(
                label: l.bibleTranslation,
                value: _formatBool(detail.raw['imb_bible_available'], l),
                isChecked: detail.raw['imb_bible_available'] ?? false,
              ),
              _DetailRow(
                label: l.bibleStories,
                value: _formatBool(
                  detail.raw['imb_bible_stories_available'],
                  l,
                ),
                isChecked: detail.raw['imb_bible_stories_available'] ?? false,
              ),
              _DetailRow(
                label: l.jesusFilm,
                value: _formatBool(detail.raw['imb_jesus_film_available'], l),
                isChecked: detail.raw['imb_jesus_film_available'] ?? false,
              ),
              _DetailRow(
                label: l.radioBroadcast,
                value: _formatBool(
                  detail.raw['imb_radio_broadcast_available'],
                  l,
                ),
                isChecked: detail.raw['imb_radio_broadcast_available'] ?? false,
              ),
              _DetailRow(
                label: l.gospelRecordings,
                value: _formatBool(
                  detail.raw['imb_gospel_recordings_available'],
                  l,
                ),
                isChecked:
                    detail.raw['imb_gospel_recordings_available'] ?? false,
              ),
              _DetailRow(
                label: l.audioScripture,
                value: _formatBool(
                  detail.raw['imb_audio_scripture_available'],
                  l,
                ),
                isChecked: detail.raw['imb_audio_scripture_available'] ?? false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.detail});

  final PeopleGroupDetail detail;

  @override
  Widget build(BuildContext context) {
    final credit = detail.pictureCredit;
    return ElevatedAppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.lg,
        children: [
          Text(
            detail.name,
            textAlign: TextAlign.center,
            style: AppTypography.titleLarge,
          ),
          Center(
            child: Stack(
              children: [
                AppImage(
                  url: detail.imageUrl,
                  aspectRatio: 1,
                  size: 240,
                  semanticLabel: detail.name,
                ),
                if (credit.isNotEmpty)
                  Positioned(
                    right: AppSpacing.lg,
                    bottom: AppSpacing.lg,
                    child: CreditPopoverButton(credit: credit),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                detail.raw['country_code']?['label'] ?? '',
                textAlign: TextAlign.center,
                style: AppTypography.titleMedium,
              ),
              Text(
                '(${detail.raw['rop1']?['label']})',
                textAlign: TextAlign.center,
                style: AppTypography.titleMedium,
              ),
            ],
          ),
          if (detail.raw['imb_people_description'] is String)
            Text(
              detail.raw['imb_people_description'] as String,
              style: AppTypography.bodyMedium,
            ),
        ],
      ),
    );
  }
}

class _CommittedProgress extends StatelessWidget {
  const _CommittedProgress({required this.committed});

  final int committed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context)!;
    final clamped = committed.clamp(0, _peopleCommittedGoal);
    final ratio = _peopleCommittedGoal == 0
        ? 0.0
        : clamped / _peopleCommittedGoal;
    return ElevatedAppCard(
      padding: AppSpacing.xxxl,
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: AppSpacing.md,
        children: [
          H1(l.prayerStatus, color: AppColors.white),
          Text(
            '$committed',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: AppTypography.xxl,
            ),
          ),
          Text(
            l.peopleCommittedToPraying,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
          ClipRRect(
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
          Text(
            l.prayerCoverage24h,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ElevatedAppCard(
      padding: AppSpacing.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.md,
        children: [
          Text(
            title,
            style: AppTypography.h2.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final w in children)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
              child: w,
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.isChecked});

  final String label;
  final String? value;
  final bool? isChecked;

  bool get isVisible => value != null && value!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xxxs),
          child: Row(
            spacing: AppSpacing.sm,
            children: [
              if (isChecked != null)
                (isChecked == true)
                    ? IconCircle(
                        icon: CheckIcon(
                          size: AppTypography.xs,
                          color: AppColors.white,
                        ),
                        color: AppColors.secondary,
                      )
                    : IconCircle(
                        icon: CloseIcon(
                          size: AppTypography.xs,
                          color: AppColors.white,
                        ),
                        color: AppColors.scheme.error,
                      ),
              SizedBox(
                width: 140,
                child: Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: Text(value!, style: AppTypography.bodyMedium)),
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
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
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

String? _formatBool(dynamic value, AppLocalizations l) {
  if (value == null) return null;
  if (value is bool) return value ? l.yes : l.no;
  return value.toString();
}

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

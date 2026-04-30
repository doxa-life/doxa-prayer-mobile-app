import 'package:doxa_prayer_mobile_app/components/buttons/select_people_group_button.dart';
import 'package:doxa_prayer_mobile_app/components/cards/elevated_card.dart';
import 'package:doxa_prayer_mobile_app/components/misc/app_image.dart';
import 'package:doxa_prayer_mobile_app/components/misc/background_image_container.dart';
import 'package:doxa_prayer_mobile_app/components/misc/credit_popover_button.dart';
import 'package:doxa_prayer_mobile_app/components/misc/titles.dart';
import 'package:doxa_prayer_mobile_app/components/nav/details_nav_bar.dart';
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
  const PeopleGroupDetailsScreen({super.key, this.slug});

  final String? slug;

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
    return BackgroundImageContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: DetailsNavBar(
          title: 'People Group',
          onBack: () => Navigator.pop(context),
        ),
        body: FutureBuilder<PeopleGroupDetail>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _ErrorView(
                message: 'Could not load people group details.',
                onRetry: _reload,
              );
            }
            final detail = snapshot.data!;
            return _DetailBody(detail: detail);
          },
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail});

  final PeopleGroupDetail detail;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SelectPeopleGroupButton(
            slug: detail.slug,
            name: detail.name,
            imageUrl: detail.imageUrl,
          ),
          const SizedBox(height: AppSpacing.xl),
          _Hero(detail: detail),
          const SizedBox(height: AppSpacing.xl),
          _CommittedProgress(committed: detail.peopleCommitted),
          const SizedBox(height: AppSpacing.xl),
          _Section(
            title: 'Description',
            children: [
              if (detail.raw['imb_people_description'] is String)
                Text(
                  detail.raw['imb_people_description'] as String,
                  style: AppTypography.bodyMedium,
                ),
            ],
          ),
          _Section(
            title: 'Identity',
            children: [
              _DetailRow(label: 'Name', value: detail.name),
              _DetailRow(label: 'Slug', value: detail.slug),
              _DetailRow(label: 'Status', value: _label(detail.raw['status'])),
              _DetailRow(
                label: 'Reason unlisted',
                value: detail.raw['reason_unlisted']?.toString(),
              ),
              _DetailRow(
                label: 'IMB alternate name',
                value: detail.raw['imb_alternate_name']?.toString(),
              ),
            ],
          ),
          _Section(
            title: 'Location',
            children: [
              _DetailRow(
                label: 'Country',
                value: _label(detail.raw['country_code']),
              ),
              _DetailRow(label: 'Region', value: _label(detail.raw['region'])),
              _DetailRow(
                label: 'IMB subregion',
                value: _label(detail.raw['imb_subregion']),
              ),
              _DetailRow(
                label: 'WAGF region',
                value: _label(detail.raw['wagf_region']),
              ),
              _DetailRow(
                label: 'WAGF block',
                value: _label(detail.raw['wagf_block']),
              ),
              _DetailRow(
                label: 'Latitude',
                value: detail.raw['latitude']?.toString(),
              ),
              _DetailRow(
                label: 'Longitude',
                value: detail.raw['longitude']?.toString(),
              ),
            ],
          ),
          _Section(
            title: 'Population',
            children: [
              _DetailRow(
                label: 'Population',
                value: _formatInt(detail.raw['population']),
              ),
              _DetailRow(
                label: 'Population class',
                value: _label(detail.raw['imb_population_class']),
              ),
              _DetailRow(
                label: 'Indigenous',
                value: _label(detail.raw['imb_is_indigenous']),
              ),
            ],
          ),
          _Section(
            title: 'People & Language',
            children: [
              _DetailRow(
                label: 'Primary language',
                value: _label(detail.raw['primary_language']),
              ),
              _DetailRow(
                label: 'Language family',
                value: _label(detail.raw['imb_language_family']),
              ),
              _DetailRow(
                label: 'Language class',
                value: _label(detail.raw['imb_language_class']),
              ),
              _DetailRow(
                label: 'Language speakers',
                value: detail.raw['imb_language_speakers']?.toString(),
              ),
              _DetailRow(
                label: 'Affinity',
                value: _label(detail.raw['imb_affinity_code']),
              ),
              _DetailRow(
                label: 'People cluster',
                value: _label(detail.raw['imb_reg_of_people_2']),
              ),
              _DetailRow(
                label: 'Region of people',
                value: _label(detail.raw['rop1']),
              ),
              _DetailRow(
                label: 'Sub-people',
                value: _label(detail.raw['imb_reg_of_people_25']),
              ),
              _DetailRow(
                label: 'Reg of people 3',
                value: detail.raw['imb_reg_of_people_3']?.toString(),
              ),
            ],
          ),
          _Section(
            title: 'Religion',
            children: [
              _DetailRow(
                label: 'Religion',
                value: _label(detail.raw['religion']),
              ),
              if (detail.raw['religion'] is Map<String, dynamic> &&
                  (detail.raw['religion']
                          as Map<String, dynamic>)['description']
                      is String)
                Text(
                  (detail.raw['religion']
                          as Map<String, dynamic>)['description']
                      as String,
                  style: AppTypography.bodySmall,
                ),
              _DetailRow(
                label: 'Religion (3-level)',
                value: _label(detail.raw['imb_reg_of_religion_3']),
              ),
              _DetailRow(
                label: 'Religion (4-level)',
                value: _label(detail.raw['imb_reg_of_religion_4']),
              ),
            ],
          ),
          _Section(
            title: 'Engagement',
            children: [
              _DetailRow(
                label: 'Engagement status',
                value: _label(detail.raw['engagement_status']),
              ),
              _DetailRow(
                label: 'Reason engaged',
                value: detail.raw['reason_engaged']?.toString(),
              ),
              _DetailRow(
                label: 'Existing congregation',
                value: _label(detail.raw['imb_congregation_existing']),
              ),
              _DetailRow(
                label: 'Church planting',
                value: _label(detail.raw['imb_church_planting']),
              ),
              _DetailRow(
                label: 'Believers count',
                value: detail.raw['believers_count']?.toString(),
              ),
              _DetailRow(
                label: 'Evangelical %',
                value: detail.raw['evangelical_pct']?.toString(),
              ),
              _DetailRow(
                label: 'Evangelical level',
                value: _label(detail.raw['imb_evangelical_level']),
              ),
              _DetailRow(label: 'GSEC', value: _label(detail.raw['imb_gsec'])),
              _DetailRow(
                label: 'Strategic priority index',
                value: detail.raw['imb_strategic_priority_index']?.toString(),
              ),
              _DetailRow(
                label: 'Lostness priority index',
                value: detail.raw['imb_lostness_priority_index']?.toString(),
              ),
              _DetailRow(
                label: 'Long-term workers',
                value: detail.raw['workers_long_term']?.toString(),
              ),
              _DetailRow(
                label: 'Work in local language',
                value: detail.raw['work_in_local_language']?.toString(),
              ),
              _DetailRow(
                label: 'Disciple & church multiplication',
                value: detail.raw['disciple_and_church_multiplication']
                    ?.toString(),
              ),
            ],
          ),
          _Section(
            title: 'Resources',
            children: [
              _DetailRow(
                label: 'Bible Translation',
                value: _formatBool(detail.raw['imb_bible_available']),
              ),
              _DetailRow(
                label: 'Bible Stories',
                value: _formatBool(detail.raw['imb_bible_stories_available']),
              ),
              _DetailRow(
                label: 'Jesus Film',
                value: _formatBool(detail.raw['imb_jesus_film_available']),
              ),
              _DetailRow(
                label: 'Radio broadcast',
                value: _formatBool(detail.raw['imb_radio_broadcast_available']),
              ),
              _DetailRow(
                label: 'Gospel recordings',
                value: _formatBool(
                  detail.raw['imb_gospel_recordings_available'],
                ),
              ),
              _DetailRow(
                label: 'Audio scripture',
                value: _formatBool(detail.raw['imb_audio_scripture_available']),
              ),
            ],
          ),
          _Section(
            title: 'Adoption & Commitment',
            children: [
              _DetailRow(
                label: 'People praying',
                value: detail.peoplePraying.toString(),
              ),
              _DetailRow(
                label: 'People committed',
                value: detail.peopleCommitted.toString(),
              ),
              _DetailRow(
                label: 'Committed duration',
                value: detail.raw['committed_duration']?.toString(),
              ),
              _DetailRow(
                label: 'Global start date',
                value: detail.raw['global_start_date']?.toString(),
              ),
              _DetailRow(
                label: 'Adopted by churches',
                value: detail.raw['adopted_by_churches']?.toString(),
              ),
              _DetailRow(
                label: 'Adopted by count',
                value: detail.raw['adopted_by_count']?.toString(),
              ),
              _DetailRow(
                label: 'Adopted by',
                value: _formatStringList(detail.raw['adopted_by_names']),
              ),
              _DetailRow(
                label: 'WAGF member',
                value: _label(detail.raw['wagf_member']),
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
                AppImage(url: detail.imageUrl, aspectRatio: 1, size: 240),
                if (credit.isNotEmpty)
                  Positioned(
                    right: AppSpacing.lg,
                    bottom: AppSpacing.lg,
                    child: CreditPopoverButton(credit: credit),
                  ),
              ],
            ),
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
    final visible = children
        .where((w) => w is! _DetailRow || w.isVisible)
        .toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: ElevatedAppCard(
        padding: AppSpacing.xl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.h2),
            const SizedBox(height: AppSpacing.md),
            for (final w in visible)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                child: w,
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String? value;

  bool get isVisible => value != null && value!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
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

String? _formatBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value ? 'Yes' : 'No';
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

String? _formatStringList(dynamic value) {
  if (value is List) {
    final items = value.whereType<String>().toList();
    if (items.isEmpty) return null;
    return items.join(', ');
  }
  return null;
}

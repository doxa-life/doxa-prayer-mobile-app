import 'dart:math' as math;

import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../components/buttons/action_button.dart';
import '../../components/cards/people_group_list_card.dart';
import '../../components/inputs/multi_select_field.dart';
import '../../components/inputs/population_range_field.dart';
import '../../components/inputs/search_field.dart';
import '../../components/inputs/select_field.dart';
import '../../components/misc/entrance_fade_slide.dart';
import '../../components/widgets/people_groups_list_skeleton.dart';
import '../../models/people_group.dart';
import '../../services/locale_controller.dart';
import '../../services/people_groups_service.dart';
import '../../services/people_group_subscription_flow.dart';
import '../../services/subscribed_people_groups_controller.dart';
import '../../theme/app_spacing.dart';
import '../misc/cached_data_builder.dart';
import '../misc/hyphenated_text.dart';

class PeopleGroupsList extends StatefulWidget {
  const PeopleGroupsList({
    super.key,
    this.onSelect,
    this.onSelectionConfirmed,
    this.listBottomPadding = 0,
  });

  /// Override the action triggered when the user taps "Select" on a group.
  /// When null, falls back to the in-app confirmation modal that persists the
  /// selection. The wizard passes a callback that advances to a confirm step
  /// instead.
  final ValueChanged<PeopleGroup>? onSelect;

  /// Called after the user confirms a selection via the details page modal.
  /// The wizard uses this to skip its in-wizard confirm step (the user already
  /// confirmed externally) and signals "in wizard" mode to the details page.
  final ValueChanged<PeopleGroup>? onSelectionConfirmed;

  /// Padding inside the scrollable list, so content can scroll to the
  /// viewport edge while keeping a gap after the last item.
  final double listBottomPadding;

  @override
  State<PeopleGroupsList> createState() => _PeopleGroupsListState();
}

class _PeopleGroupsListState extends State<PeopleGroupsList> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _filtersExpanded = false;
  bool _sortAscending = true;

  Set<String> _languageFilters = {};
  String? _religionFilter;
  String? _statusFilter;
  Set<String> _countryFilters = {};

  // null = no population filter applied (the slider still shows the full
  // data-derived range).
  RangeValues? _populationRange;

  /// The wizard passes [onSelectionConfirmed]; the standalone list doesn't.
  bool get _isWizardMode => widget.onSelect != null;

  bool get _hasActiveFilters =>
      _languageFilters.isNotEmpty ||
      _religionFilter != null ||
      _statusFilter != null ||
      _countryFilters.isNotEmpty ||
      _populationRange != null;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _languageFilters = {};
      _religionFilter = null;
      _statusFilter = null;
      _countryFilters = {};
      _populationRange = null;
    });
  }

  /// Splits on anything that isn't a letter or digit, so each name breaks
  /// into its actual words.
  static final RegExp _wordSplitter = RegExp(r'[^\p{L}\p{N}]+', unicode: true);

  /// Whether [query] prefix-matches any *word* in [name] — not a bare
  /// substring search. A plain `contains` would match "al" against "Akha
  /// Pala" (the "al" inside "Pala"), which reads as a broken result.
  static bool _matchesQuery(String name, String query) {
    if (query.isEmpty) return true;
    final words = name.toLowerCase().split(_wordSplitter);
    return words.any((w) => w.startsWith(query));
  }

  List<PeopleGroup> _filter(List<PeopleGroup> groups) {
    final q = _query.trim().toLowerCase();
    final filtered = groups.where((g) {
      final matchesQuery = _matchesQuery(g.name.toLowerCase(), q);
      final matchesLanguage =
          _languageFilters.isEmpty ||
          (g.primaryLanguageLabel != null &&
              _languageFilters.contains(g.primaryLanguageLabel));
      final matchesReligion =
          _religionFilter == null || g.religionLabel == _religionFilter;
      final matchesStatus =
          _statusFilter == null || g.engagementStatusValue == _statusFilter;
      final matchesCountry =
          _countryFilters.isEmpty ||
          (g.countryCode != null && _countryFilters.contains(g.countryCode));
      final range = _populationRange;
      final matchesPopulation =
          range == null ||
          g.population == null ||
          (g.population! >= range.start && g.population! <= range.end);
      return matchesQuery &&
          matchesLanguage &&
          matchesReligion &&
          matchesStatus &&
          matchesCountry &&
          matchesPopulation;
    }).toList();
    filtered.sort((a, b) {
      final cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return _sortAscending ? cmp : -cmp;
    });
    return filtered;
  }

  /// Distinct, sorted labels present in [groups], for the filter options.
  List<String> _distinctLabels(
    List<PeopleGroup> groups,
    String? Function(PeopleGroup) selector,
  ) {
    final labels = groups.map(selector).whereType<String>().toSet().toList();
    labels.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return labels;
  }

  String _continentLabel(String? regionValue, AppLocalizations l) =>
      switch (regionValue) {
        'asia' => l.continentAsia,
        'africa' => l.continentAfrica,
        'americas' => l.continentAmericas,
        'europe' => l.continentEurope,
        'oceania' => l.continentOceania,
        _ => l.continentOther,
      };

  /// Country options for the country filter, grouped by continent. The
  /// continent comes from each group's own region field, so no separate
  /// country dataset is needed.
  List<MultiSelectOption<String>> _countryOptions(
    List<PeopleGroup> groups,
    AppLocalizations l,
  ) {
    final byCode = <String, (String label, String? region)>{};
    for (final g in groups) {
      final code = g.countryCode;
      final label = g.countryLabel;
      if (code == null || label == null) continue;
      byCode[code] = (label, g.regionValue);
    }
    final entries = byCode.entries.toList()
      ..sort((a, b) {
        final continentCompare = _continentLabel(
          a.value.$2,
          l,
        ).compareTo(_continentLabel(b.value.$2, l));
        if (continentCompare != 0) return continentCompare;
        return a.value.$1.toLowerCase().compareTo(b.value.$1.toLowerCase());
      });
    return [
      for (final e in entries)
        MultiSelectOption(
          value: e.key,
          label: e.value.$1,
          groupLabel: _continentLabel(e.value.$2, l),
        ),
    ];
  }

  /// The (min, max) population across [groups], for the slider bounds. (0, 0)
  /// while nothing has a population yet, which hides the slider.
  (int, int) _populationBounds(List<PeopleGroup> groups) {
    final populations = groups.map((g) => g.population).whereType<int>();
    if (populations.isEmpty) return (0, 0);
    return (populations.reduce(math.min), populations.reduce(math.max));
  }

  Future<void> _openDetails(PeopleGroup group) async {
    final fromWizard = widget.onSelectionConfirmed != null;
    final confirmed = await context.push<bool>(
      '/people-groups/${group.slug}',
      extra: {'fromWizard': fromWizard},
    );
    if (!mounted) return;
    if (confirmed == true) widget.onSelectionConfirmed?.call(group);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.lg,
      children: [
        Row(
          spacing: AppSpacing.md,
          children: [
            Expanded(
              child: SearchField(
                hint: l.searchPeopleGroups,
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                onClear: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              ),
            ),
            IconButton(
              icon: Badge(
                isLabelVisible: _hasActiveFilters,
                child: Icon(
                  Icons.tune,
                  // Tinted while the panel is open, so the toggled state shows
                  // even when no filter is active yet.
                  color: _filtersExpanded
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
              tooltip: l.filters,
              onPressed: () =>
                  setState(() => _filtersExpanded = !_filtersExpanded),
            ),
          ],
        ),
        Expanded(
          // The list is fetched in the app's language, so switching language
          // re-reads it under that language's cache key.
          child: ValueListenableBuilder<Locale>(
            valueListenable: localeController,
            builder: (context, locale, _) {
              final lang = locale.languageCode;
              return CachedDataBuilder<List<PeopleGroup>>(
                cacheKey: peopleGroupListCacheKey(lang),
                fetch: ({bool forceRefresh = false}) =>
                    fetchPeopleGroups(lang: lang, forceRefresh: forceRefresh),
                loading: (context) => PeopleGroupsListSkeleton(
                  bottomPadding: widget.listBottomPadding,
                ),
                error: (context, retry) => _ErrorView(
                  message: AppLocalizations.of(
                    context,
                  )!.couldNotLoadPeopleGroupsMessage,
                  onRetry: retry,
                ),
                builder: (context, groups) => _buildList(context, groups),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSortRow(AppLocalizations l) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: HyphenatedText(
            l.sortByName,
            style: AppTypography.bodyMedium.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
          ),
          tooltip: _sortAscending ? l.sortDescending : l.sortAscending,
          onPressed: () => setState(() => _sortAscending = !_sortAscending),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context, List<PeopleGroup> groups) {
    final l = AppLocalizations.of(context)!;
    final filtered = _filter(groups);
    final languages = _distinctLabels(groups, (g) => g.primaryLanguageLabel);
    final religions = _distinctLabels(groups, (g) => g.religionLabel);
    final countryOptions = _countryOptions(groups, l);
    final (popMin, popMax) = _populationBounds(groups);
    final populationValue =
        _populationRange ?? RangeValues(popMin.toDouble(), popMax.toDouble());
    return ValueListenableBuilder<SubscribedPeopleGroups>(
      valueListenable: peopleGroupsController,
      builder: (context, subscribed, _) {
        // The results count scrolls with the list (it is the first entry), so
        // only the search row and the optional filter panel stay fixed above.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.lg,
          children: [
            if (_filtersExpanded) ...[
              _buildSortRow(l),
              MultiSelectField<String>(
                label: l.primaryLanguage,
                emptyLabel: l.allLanguages,
                options: [
                  for (final lang in languages)
                    MultiSelectOption(value: lang, label: lang),
                ],
                selected: _languageFilters,
                searchable: true,
                onChanged: (v) => setState(() => _languageFilters = v),
              ),
              SelectField<String?>(
                label: l.primaryReligion,
                value: religions.contains(_religionFilter)
                    ? _religionFilter
                    : null,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: HyphenatedText(l.allReligions),
                  ),
                  for (final r in religions)
                    DropdownMenuItem<String?>(
                      value: r,
                      child: HyphenatedText(r),
                    ),
                ],
                onChanged: (v) => setState(() => _religionFilter = v),
              ),
              SelectField<String?>(
                label: l.status,
                value: _statusFilter,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: HyphenatedText(l.allStatuses),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'engaged',
                    child: HyphenatedText(l.engaged),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'unengaged',
                    child: HyphenatedText(l.unengaged),
                  ),
                ],
                onChanged: (v) => setState(() => _statusFilter = v),
              ),
              if (countryOptions.isNotEmpty)
                MultiSelectField<String>(
                  label: l.country,
                  emptyLabel: l.allCountries,
                  options: countryOptions,
                  selected: _countryFilters,
                  searchable: true,
                  onChanged: (v) => setState(() => _countryFilters = v),
                ),
              if (popMax > popMin)
                PopulationRangeField(
                  min: popMin,
                  max: popMax,
                  value: populationValue,
                  onChanged: (v) => setState(() => _populationRange = v),
                ),
              if (_hasActiveFilters)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _clearFilters,
                    child: HyphenatedText(l.clearFilters),
                  ),
                ),
            ],
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.only(bottom: widget.listBottomPadding),
                itemCount: filtered.length + 1,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.lg),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return HyphenatedText(
                      l.nPeopleGroups(filtered.length),
                      style: AppTypography.caption,
                    );
                  }
                  final g = filtered[i - 1];
                  // Stagger only the first few cards so the initial list
                  // settles in with a gentle cascade.
                  final delay = Duration(
                    milliseconds: 40 * math.min(i - 1, 8),
                  );
                  final inWizard = _isWizardMode;
                  return EntranceFadeSlide(
                    key: ValueKey(g.slug),
                    delay: delay,
                    child: PeopleGroupListCard(
                      name: g.name,
                      countryLabel: g.countryLabel,
                      imageUrl: g.imageUrl,
                      engagementStatusValue: g.engagementStatusValue,
                      peoplePraying: g.peoplePraying,
                      isSelected: subscribed.contains(g.slug),
                      // The wizard keeps its in-list select button; the
                      // standalone list uses the card as the tap target.
                      showSelectButton: inWizard,
                      // Only outside the wizard: mid-onboarding the list is
                      // choosing a first group, not managing a set.
                      onUnselect: inWizard
                          ? null
                          : () => removePeopleGroupFlow(context, slug: g.slug),
                      onSelect: () => widget.onSelect?.call(g),
                      onDetails: () => _openDetails(g),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.lg,
        children: [
          HyphenatedText(message, textAlign: TextAlign.center),
          ActionButton(
            label: AppLocalizations.of(context)!.retry,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

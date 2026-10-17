import 'dart:math' as math;

import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../../components/buttons/action_button.dart';
import '../../components/cards/people_group_list_card.dart';
import '../../components/inputs/checkbox_field.dart';
import '../../components/inputs/filter_section.dart';
import '../../components/inputs/multi_select_field.dart';
import '../../components/inputs/population_range_field.dart';
import '../../components/inputs/search_field.dart';
import '../../components/misc/collapsible.dart';
import '../../components/misc/entrance_fade_slide.dart';
import '../../components/nav/sheet_page.dart';
import '../../components/widgets/people_groups_list_skeleton.dart';
import '../../models/people_group.dart';
import '../../models/prayer_content.dart';
import '../../services/locale_controller.dart';
import '../../services/people_group_of_the_day.dart';
import '../../services/people_groups_service.dart';
import '../../services/people_group_subscription_flow.dart';
import '../../services/subscribed_people_groups_controller.dart';
import '../../theme/app_colors.dart';
import '../../layouts/page_scaffold.dart';
import '../../theme/app_spacing.dart';
import '../misc/cached_data_builder.dart';
import '../misc/country_flag.dart';
import '../misc/religion_icon.dart';
import '../misc/hyphenated_text.dart';

class PeopleGroupsList extends StatefulWidget {
  const PeopleGroupsList({
    super.key,
    this.onSelect,
    this.onSelectionConfirmed,
    this.listBottomPadding = 0,
    this.fullBleed = false,
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

  /// Whether the list fills the screen edge to edge and pads itself, as on the
  /// Search tab. The search bar then sits on a full-width white band, which
  /// the filter menu drops down from as one continuous surface. Otherwise (the
  /// wizard) the list sits inside the caller's padding as before.
  final bool fullBleed;

  @override
  State<PeopleGroupsList> createState() => _PeopleGroupsListState();
}

class _PeopleGroupsListState extends State<PeopleGroupsList> {
  final _CountryFlagSearchController _searchController =
      _CountryFlagSearchController();

  /// The list last shown, so the search box can tell a typed country name
  /// from any other search.
  List<PeopleGroup>? _loadedGroups;

  /// Today's People Group of the Day for the active group, once read, and
  /// which group, language and day it was read for.
  PeopleGroupBlockData? _ofTheDay;
  String? _ofTheDayKey;
  String _query = '';
  bool _filtersExpanded = false;
  bool _sortAscending = true;

  /// How much of the results list stays visible under an open filter menu.
  static const double _listRoomBelowMenu = 160;

  /// The filter menu's "Prioritize groups with the fewest intercessors" box.
  /// On by default, so the groups that most need prayer are seen first.
  /// Unticking it counts as changing a filter: the reset button appears, and
  /// resetting ticks it again.
  bool _prioritizeFewest = true;

  /// Whether the opening cascade has played. Only cards in the list's first
  /// frame animate in; cards built later, as the user scrolls, appear at once
  /// so they're already there when they come into view. Changing a filter or
  /// the sort plays it again (see [_updateResults]).
  bool _cascadePlayed = false;

  /// Bumped whenever a filter or the sort changes. Part of each card's key,
  /// so the cards are rebuilt and settle in again rather than the list
  /// jumping to its new contents.
  int _resultsGeneration = 0;

  /// The population section is the only one that opens in place; the others
  /// open a picker sheet or carry their control in the header.
  bool _populationOpen = false;

  Set<String> _languageFilters = {};
  Set<String> _religionFilters = {};
  String? _statusFilter;
  Set<String> _countryFilters = {};

  // null = no population filter applied (the slider still shows the full
  // data-derived range).
  RangeValues? _populationRange;

  /// The filter menu's options, worked out from the whole list. Kept between
  /// builds — they only change with the list itself or the language — rather
  /// than redone from ~2,100 groups on every keystroke and filter tap.
  List<PeopleGroup>? _optionsFor;
  AppLocalizations? _optionsLocale;
  late List<String> _languageLabels;
  late List<String> _religionLabels;
  late List<MultiSelectOption<String>> _countryChoices;
  late (int, int) _populationLimits;

  void _computeOptions(List<PeopleGroup> groups, AppLocalizations l) {
    if (identical(groups, _optionsFor) && identical(l, _optionsLocale)) return;
    _optionsFor = groups;
    _optionsLocale = l;
    _languageLabels = _distinctLabels(groups, (g) => g.primaryLanguageLabel);
    _religionLabels = _distinctLabels(groups, (g) => g.religionLabel);
    _countryChoices = _countryOptions(groups, l);
    _populationLimits = _populationBounds(groups);
  }

  void _closeFilters() {
    if (_filtersExpanded) setState(() => _filtersExpanded = false);
  }

  /// The wizard passes [onSelectionConfirmed]; the standalone list doesn't.
  bool get _isWizardMode => widget.onSelect != null;

  bool get _hasActiveFilters =>
      _languageFilters.isNotEmpty ||
      _religionFilters.isNotEmpty ||
      _statusFilter != null ||
      _countryFilters.isNotEmpty ||
      _populationRange != null ||
      !_prioritizeFewest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Applies a filter or sort [change] and replays the cards' entrance, so
  /// the results visibly settle into their new state.
  void _updateResults(VoidCallback change) {
    setState(() {
      change();
      _resultsGeneration++;
      _cascadePlayed = false;
    });
  }

  void _clearFilters() {
    _updateResults(() {
      _languageFilters = {};
      _religionFilters = {};
      _statusFilter = null;
      _countryFilters = {};
      _populationRange = null;
      _prioritizeFewest = true;
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

  /// The filter values the search box matches, as if they'd been picked in
  /// that filter. [textsByValue] maps each filter value to the texts it's
  /// known by. Each query word must be a *whole* word of one of those texts,
  /// so a half-typed "mus" or "ind" doesn't pull in every Islam or Indian
  /// group — only names match until the filter value is spelled out. Labels
  /// come translated, so this works in every language.
  static Set<String> _valuesMatching(
    Map<String, List<String>> textsByValue,
    String query,
  ) {
    final queryWords = query.split(_wordSplitter).where((w) => w.isNotEmpty);
    if (queryWords.isEmpty) return const {};
    return {
      for (final MapEntry(key: value, value: texts) in textsByValue.entries)
        if (_allWordsAreWords(queryWords, texts)) value,
    };
  }

  /// Religion labels the query matches: "sunni" finds "Islam - Sunni",
  /// "shia" both Shia religions, and "muslim" every Islam religion through
  /// its alternate names.
  Set<String> _religionsMatching(List<PeopleGroup> groups, String query) =>
      _valuesMatching({
        for (final g in groups)
          if (g.religionLabel != null)
            g.religionLabel!: [g.religionLabel!, ...g.religionAlternates],
      }, query);

  /// Words of a text with where each ends, for finding country names in
  /// the search box.
  static final RegExp _wordPattern = RegExp(r'[\p{L}\p{N}]+', unicode: true);

  /// The countries named in [text], each with the offset where its name ends
  /// (for drawing its flag there). The text has to be made up *entirely* of
  /// whole country names — "india", "united states", "india pakistan" — so
  /// a word shared by several countries, like "united", or a search that
  /// mixes in other words, matches no country. Empty when it doesn't.
  List<(String code, int end)> _countriesNamed(
    List<PeopleGroup> groups,
    String text,
  ) {
    final codesByName = <String, String>{
      for (final g in groups)
        if (g.countryCode != null && g.countryLabel != null)
          _wordsOf(g.countryLabel!): g.countryCode!,
    };
    final longest = codesByName.keys.fold(
      0,
      (n, name) => math.max(n, name.split(' ').length),
    );
    final words = _wordPattern.allMatches(text).toList();
    final found = <(String, int)>[];
    var i = 0;
    while (i < words.length) {
      // Longest name first, so "guinea bissau" isn't read as "guinea".
      var matched = false;
      for (var n = math.min(longest, words.length - i); n > 0; n--) {
        final name = [
          for (final w in words.sublist(i, i + n)) w[0]!.toLowerCase(),
        ].join(' ');
        final code = codesByName[name];
        if (code == null) continue;
        found.add((code, words[i + n - 1].end));
        i += n;
        matched = true;
        break;
      }
      if (!matched) return const [];
    }
    return found;
  }

  /// Country codes the query names (see [_countriesNamed]).
  Set<String> _countriesMatching(List<PeopleGroup> groups, String query) => {
    for (final (code, _) in _countriesNamed(groups, query)) code,
  };

  /// [text] lowercased with punctuation and extra spaces collapsed, so
  /// "Congo, Democratic Republic of" compares equal however it's spaced.
  static String _wordsOf(String text) => text
      .toLowerCase()
      .split(_wordSplitter)
      .where((w) => w.isNotEmpty)
      .join(' ');

  /// Primary-language labels the query matches.
  Set<String> _languagesMatching(List<PeopleGroup> groups, String query) =>
      _valuesMatching({
        for (final g in groups)
          if (g.primaryLanguageLabel != null)
            g.primaryLanguageLabel!: [g.primaryLanguageLabel!],
      }, query);

  /// Region values the query matches by continent name ("africa"). The
  /// catch-all "other" continent is left out so typing "other" doesn't match.
  Set<String> _continentsMatching(
    List<PeopleGroup> groups,
    String query,
    AppLocalizations l,
  ) => _valuesMatching({
    for (final g in groups)
      if (g.regionValue case final region?
          when _continentLabel(region, l) != l.continentOther)
        region: [_continentLabel(region, l)],
  }, query);

  /// Engagement status values the query matches ("unengaged").
  Set<String> _statusesMatching(String query, AppLocalizations l) =>
      _valuesMatching({
        'engaged': [l.engaged],
        'unengaged': [l.unengaged],
      }, query);

  static bool _allWordsAreWords(
    Iterable<String> queryWords,
    List<String> texts,
  ) {
    final words = {
      for (final t in texts) ...t.toLowerCase().split(_wordSplitter),
    };
    return queryWords.every(words.contains);
  }

  List<PeopleGroup> _filter(List<PeopleGroup> groups, AppLocalizations l) {
    final q = _query.trim().toLowerCase();
    final religionMatches = _religionsMatching(groups, q);
    final countryMatches = _countriesMatching(groups, q);
    final languageMatches = _languagesMatching(groups, q);
    final continentMatches = _continentsMatching(groups, q, l);
    final statusMatches = _statusesMatching(q, l);
    final filtered = groups.where((g) {
      final matchesQuery =
          _matchesQuery(g.name, q) ||
          religionMatches.contains(g.religionLabel) ||
          countryMatches.contains(g.countryCode) ||
          languageMatches.contains(g.primaryLanguageLabel) ||
          continentMatches.contains(g.regionValue) ||
          statusMatches.contains(g.engagementStatusValue);
      final matchesLanguage =
          _languageFilters.isEmpty ||
          (g.primaryLanguageLabel != null &&
              _languageFilters.contains(g.primaryLanguageLabel));
      final matchesReligion =
          _religionFilters.isEmpty ||
          (g.religionLabel != null &&
              _religionFilters.contains(g.religionLabel));
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
      // With the box ticked, the groups with the fewest intercessors come
      // first — the count each card shows — and each run with the same count
      // follows the A–Z / Z–A button.
      //
      // Deliberately not `compareByPrayerNeed`, which "pick a group for me"
      // uses: it breaks ties on outreach resources, which no card shows, so
      // within one count the names ran A–Z, then started over at A for the
      // next resource tier, and the list read as broken.
      if (_prioritizeFewest) {
        final need = a.peopleCommitted.compareTo(b.peopleCommitted);
        if (need != 0) return need;
      }
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
          leading: CountryFlag(code: e.key, height: 16),
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
    final confirmed = await pushSheet<bool>(
      context,
      '/people-groups/${group.slug}',
      extra: {'fromWizard': fromWizard},
    );
    if (!mounted) return;
    if (confirmed == true) widget.onSelectionConfirmed?.call(group);
  }

  /// Religion label → its API code, for the religion icons.
  Map<String, String> _religionCodes(List<PeopleGroup> groups) => {
    for (final g in groups)
      if (g.religionLabel != null && g.religionCode != null)
        g.religionLabel!: g.religionCode!,
  };

  /// The badges to draw in the search text, the way X decorates some
  /// hashtags, each with the offset it follows: a flag after each country
  /// named ("india pakistan" gets two), otherwise the religion's icon at the
  /// end when every religion the query matches shares one ("muslim" → the
  /// mosque). Empty when neither applies.
  List<(int, _SearchBadge)> _badgesForQuery() {
    final groups = _loadedGroups;
    if (groups == null) return const [];
    final text = _searchController.text;
    final countries = _countriesNamed(groups, text);
    if (countries.isNotEmpty) {
      return [
        for (final (code, end) in countries) (end, _SearchBadge.flag(code)),
      ];
    }
    final codes = _religionCodes(groups);
    final icons = {
      for (final label in _religionsMatching(groups, text.trim().toLowerCase()))
        religionIconFor(codes[label]),
    };
    final end = _wordPattern.allMatches(text).lastOrNull?.end;
    if (end != null && icons.length == 1 && icons.single != null) {
      return [(end, _SearchBadge.religion(icons.single!))];
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    _searchController.badges = _badgesForQuery();
    final searchBar = Row(
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
          onPressed: () {
            FocusScope.of(context).unfocus();
            setState(() => _filtersExpanded = !_filtersExpanded);
          },
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: widget.fullBleed ? 0 : AppSpacing.lg,
      children: [
        if (widget.fullBleed)
          ColoredBox(
            color: AppColors.surface,
            child: PageContainer(
              verticalPadding: AppSpacing.lg,
              child: searchBar,
            ),
          )
        else
          searchBar,
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
                loading: (context) => _padded(
                  PeopleGroupsListSkeleton(
                    bottomPadding: widget.listBottomPadding,
                  ),
                  top: AppSpacing.lg,
                ),
                error: (context, retry) => _padded(
                  _ErrorView(
                    message: AppLocalizations.of(
                      context,
                    )!.couldNotLoadPeopleGroupsMessage,
                    onRetry: retry,
                  ),
                  top: AppSpacing.lg,
                ),
                builder: (context, groups) => _buildList(context, groups),
              );
            },
          ),
        ),
      ],
    );
  }

  /// In [PeopleGroupsList.fullBleed] mode, gives [child] the page's side
  /// padding (and [top]) that the caller would otherwise have given the list.
  Widget _padded(Widget child, {double top = 0}) {
    if (!widget.fullBleed) return child;
    return PageContainer(verticalPadding: top, bottomPadding: 0, child: child);
  }

  /// Opens the picker sheet for a list filter — the usual mobile pattern —
  /// and applies the choice once the user taps Done.
  Future<void> _pick(
    String title,
    List<MultiSelectOption<String>> options,
    Set<String> selected,
    ValueChanged<Set<String>> apply,
  ) async {
    FocusScope.of(context).unfocus();
    final result = await showMultiSelectSheet<String>(
      context: context,
      title: title,
      options: options,
      initialSelection: selected,
      searchable: true,
    );
    if (result == null || !mounted) return;
    if (result.length == selected.length && result.containsAll(selected)) {
      return;
    }
    _updateResults(() => apply(result));
  }

  Widget _buildFilterPanel(
    AppLocalizations l, {
    required List<String> languages,
    required List<String> religions,
    required List<MultiSelectOption<String>> countryOptions,
    required int popMin,
    required int popMax,
    required RangeValues populationValue,
  }) {
    final languageOptions = [
      for (final lang in languages) MultiSelectOption(value: lang, label: lang),
    ];
    final religionCodes = _religionCodes(_loadedGroups ?? const []);
    final religionOptions = [
      for (final r in religions)
        MultiSelectOption(
          value: r,
          label: r,
          // Only the religions that have an icon get one.
          leading: religionIconFor(religionCodes[r]) == null
              ? null
              : ReligionIcon(code: religionCodes[r]),
        ),
    ];
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : Collapsible.duration;
    final sections = <Widget>[
      FilterSection(
        title: l.primaryLanguage,
        isActive: _languageFilters.isNotEmpty,
        semanticValue: multiSelectSummary(
          l,
          options: languageOptions,
          selected: _languageFilters,
          emptyLabel: l.allLanguages,
        ),
        onTap: () => _pick(
          l.primaryLanguage,
          languageOptions,
          _languageFilters,
          (v) => _languageFilters = v,
        ),
      ),
      FilterSection(
        title: l.primaryReligion,
        isActive: _religionFilters.isNotEmpty,
        semanticValue: multiSelectSummary(
          l,
          options: religionOptions,
          selected: _religionFilters,
          emptyLabel: l.allReligions,
        ),
        onTap: () => _pick(
          l.primaryReligion,
          religionOptions,
          _religionFilters,
          (v) => _religionFilters = v,
        ),
      ),
      if (countryOptions.isNotEmpty)
        FilterSection(
          title: l.country,
          isActive: _countryFilters.isNotEmpty,
          semanticValue: multiSelectSummary(
            l,
            options: countryOptions,
            selected: _countryFilters,
            emptyLabel: l.allCountries,
          ),
          onTap: () => _pick(
            l.country,
            countryOptions,
            _countryFilters,
            (v) => _countryFilters = v,
          ),
        ),
      FilterSection(
        title: l.status,
        isActive: _statusFilter != null,
        // Tapping the chosen side again turns the filter back off.
        trailing: SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'engaged', label: HyphenatedText(l.engaged)),
            ButtonSegment(
              value: 'unengaged',
              label: HyphenatedText(l.unengaged),
            ),
          ],
          selected: {?_statusFilter},
          emptySelectionAllowed: true,
          showSelectedIcon: false,
          onSelectionChanged: (v) =>
              _updateResults(() => _statusFilter = v.firstOrNull),
        ),
      ),
      if (popMax > popMin)
        FilterSection(
          title: l.population,
          isActive: _populationRange != null,
          semanticValue:
              '${PopulationRangeField.format(populationValue.start)} – '
              '${PopulationRangeField.format(populationValue.end)}',
          expanded: _populationOpen,
          onTap: () => setState(() => _populationOpen = !_populationOpen),
          child: PopulationRangeField(
            min: popMin,
            max: popMax,
            value: populationValue,
            showLabel: false,
            // Dragging updates the list live; the cards settle in again
            // once the user lets go, not on every step of the drag.
            onChanged: (v) => setState(() => _populationRange = v),
            onChangeEnd: () => _updateResults(() {}),
          ),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Always laid out, just invisible while no filter is set, so the
        // button fading in doesn't push the sections below it down.
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: IgnorePointer(
            ignoring: !_hasActiveFilters,
            child: ExcludeSemantics(
              excluding: !_hasActiveFilters,
              child: AnimatedScale(
                scale: _hasActiveFilters ? 1 : 0.85,
                duration: duration,
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: _hasActiveFilters ? 1 : 0,
                  duration: duration,
                  child: TextButton.icon(
                    icon: const Icon(Icons.restart_alt),
                    label: HyphenatedText(l.clearFilters),
                    onPressed: _clearFilters,
                  ),
                ),
              ),
            ),
          ),
        ),
        for (final (i, section) in sections.indexed) ...[
          if (i > 0) const Divider(height: 1),
          section,
        ],
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: CheckboxField(
            label: l.prioritizeFewestIntercessors,
            value: _prioritizeFewest,
            onChanged: (v) => _updateResults(() => _prioritizeFewest = v),
          ),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context, List<PeopleGroup> groups) {
    _loadedGroups = groups;
    final l = AppLocalizations.of(context)!;
    final filtered = _filter(groups, l);
    _computeOptions(groups, l);
    final languages = _languageLabels;
    final religions = _religionLabels;
    final countryOptions = _countryChoices;
    final (popMin, popMax) = _populationLimits;
    final populationValue =
        _populationRange ?? RangeValues(popMin.toDouble(), popMax.toDouble());
    if (!_cascadePlayed) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _cascadePlayed = true,
      );
    }
    final panel = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: _buildFilterPanel(
        l,
        languages: languages,
        religions: religions,
        countryOptions: countryOptions,
        popMin: popMin,
        popMax: popMax,
        populationValue: populationValue,
      ),
    );
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          // The results never move or resize for the menu: it floats over
          // them instead of pushing them down, so opening it re-lays out
          // nothing underneath.
          Positioned.fill(child: _padded(_buildResults(context, filtered))),

          // Dims the results under an open menu. Tapping it, or starting to
          // drag the list beneath it, closes the menu and hands the list back.
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_filtersExpanded,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeFilters,
                onVerticalDragStart: (_) => _closeFilters(),
                child: AnimatedOpacity(
                  opacity: _filtersExpanded ? 1 : 0,
                  duration: reduceMotion ? Duration.zero : Collapsible.duration,
                  curve: Curves.easeOutCubic,
                  child: ColoredBox(
                    color: AppColors.black.withValues(alpha: 0.18),
                  ),
                ),
              ),
            ),
          ),

          // Pinned to the top of the results, so the filter button opens it in
          // view however far the list is scrolled. Capped so a strip of the
          // dimmed list stays below it to tap; with several sections open the
          // menu scrolls itself.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Collapsible(
              expanded: _filtersExpanded,
              // Its own layer, so the open/close animation moves already
              // painted pixels rather than repainting every section per frame.
              child: RepaintBoundary(
                child: Material(
                  color: AppColors.surface,
                  elevation: 6,
                  shadowColor: AppColors.black.withValues(alpha: 0.35),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ConstrainedBox(
                        // As tall as the menu needs, leaving the list a strip
                        // at the bottom; it only scrolls when even that won't
                        // fit (a short screen, large text, Population open).
                        constraints: BoxConstraints(
                          maxHeight: math.max(
                            constraints.maxHeight - _listRoomBelowMenu,
                            constraints.maxHeight * 0.5,
                          ),
                        ),
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: _padded(panel),
                        ),
                      ),
                      _MenuEdge(visible: _filtersExpanded),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The results count, with the sort button beside it. One tap flips the
  /// order: the arrow turns over and the label slides to the new order.
  Widget _buildCountAndSort(AppLocalizations l, int count) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : Collapsible.duration;
    final label = _sortAscending ? l.sortAZ : l.sortZA;
    return Row(
      spacing: AppSpacing.md,
      children: [
        Expanded(
          child: HyphenatedText(
            l.nPeopleGroups(count),
            style: AppTypography.caption,
          ),
        ),
        // The tooltip (and screen-reader label) spells the order out, since
        // the short "A–Z" reads as two letters.
        Tooltip(
          message: _sortAscending ? l.sortAscending : l.sortDescending,
          excludeFromSemantics: true,
          child: Semantics(
            button: true,
            label: _sortAscending ? l.sortAscending : l.sortDescending,
            excludeSemantics: true,
            child: TextButton.icon(
              icon: AnimatedRotation(
                turns: _sortAscending ? 0 : 0.5,
                duration: duration,
                curve: Curves.easeInOutCubic,
                child: const Icon(Icons.arrow_downward),
              ),
              label: AnimatedSwitcher(
                duration: duration,
                transitionBuilder: (child, animation) {
                  // The incoming label slides in the way the arrow now
                  // points; the outgoing one leaves the other way.
                  final incoming = child.key == ValueKey(label);
                  final from = (incoming == _sortAscending) ? -0.5 : 0.5;
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween(
                        begin: Offset(0, from),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(label, key: ValueKey(label)),
              ),
              onPressed: () =>
                  _updateResults(() => _sortAscending = !_sortAscending),
            ),
          ),
        ),
      ],
    );
  }

  /// Today's People Group of the Day for the active group [slug] — null until
  /// it has been read, and in the wizard, where there is no active group yet.
  /// A change of group, language or day reads it again; the setState when it
  /// lands pins it to the top of the results.
  PeopleGroupBlockData? _peopleGroupOfTheDay(String? slug) {
    if (_isWizardMode || slug == null) return null;
    final language = localeController.value.languageCode;
    final now = DateTime.now();
    final key = '$slug-$language-${now.year}-${now.month}-${now.day}';
    if (key != _ofTheDayKey) {
      _ofTheDayKey = key;
      _ofTheDay = null;
      fetchPeopleGroupOfTheDay(slug: slug, language: language).then(
        (day) {
          if (mounted && _ofTheDayKey == key) setState(() => _ofTheDay = day);
        },
        // Without it the list simply shows no pinned group.
        onError: (Object _) {},
      );
    }
    return _ofTheDay;
  }

  Widget _buildResults(BuildContext context, List<PeopleGroup> results) {
    final l = AppLocalizations.of(context)!;
    return ValueListenableBuilder<SubscribedPeopleGroups>(
      valueListenable: peopleGroupsController,
      builder: (context, subscribed, _) {
        // The People Group of the Day leads the results, outlined, whenever
        // the search and filters leave it in them.
        var filtered = results;
        String? ofTheDaySlug;
        final day = _peopleGroupOfTheDay(subscribed.active?.slug);
        if (day != null) {
          final index = indexOfPeopleGroupOfTheDay(results, day);
          if (index >= 0) {
            ofTheDaySlug = results[index].slug;
            filtered = [
              results[index],
              ...results.take(index),
              ...results.skip(index + 1),
            ];
          }
        }
        // The results count and sort button scroll with the list (they are
        // the first entry).
        return ListView.separated(
          // Edge to edge, the list starts below the search band rather than a
          // gap the caller left, so it keeps that gap itself.
          padding: EdgeInsets.only(
            top: widget.fullBleed ? AppSpacing.lg : 0,
            bottom: widget.listBottomPadding,
          ),
          // Swiping the results puts the keyboard away, so it doesn't sit
          // over the list once the user has finished typing.
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          // Builds cards half a screen past each edge, so they (and their
          // photos) are ready before they scroll into view.
          scrollCacheExtent: const ScrollCacheExtent.viewport(0.5),
          itemCount: filtered.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
          itemBuilder: (context, i) {
            if (i == 0) return _buildCountAndSort(l, filtered.length);
            final g = filtered[i - 1];
            // The first cards settle in with a gentle cascade; anything built
            // after that first frame shows straight away.
            final delay = Duration(milliseconds: 40 * math.min(i - 1, 8));
            final inWizard = _isWizardMode;
            final card = KeyedSubtree(
              key: ValueKey((_resultsGeneration, g.slug)),
              child: EntranceFadeSlide(
                key: ValueKey(g.slug),
                animate: !_cascadePlayed,
                delay: delay,
                child: PeopleGroupListCard(
                  name: g.name,
                  countryLabel: g.countryLabel,
                  countryCode: g.countryCode,
                  imageUrl: g.imageUrl,
                  engagementStatusValue: g.engagementStatusValue,
                  peoplePraying: g.peopleCommitted,
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
                  tag: g.slug == ofTheDaySlug ? l.peopleGroupOfTheDay : null,
                ),
              ),
            );
            if (g.slug != ofTheDaySlug) return card;
            return _OfTheDayHighlight(child: card);
          },
        );
      },
    );
  }
}

/// The People Group of the Day's card in the results, outlined; the card
/// itself carries the label saying why it comes first.
class _OfTheDayHighlight extends StatelessWidget {
  const _OfTheDayHighlight({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Drawn over the card, so the outline follows its rounded corners without
    // changing its size.
    return Container(
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: AppColors.secondary, width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

/// What the search box shows after the text: a country's flag or a
/// religion's icon. Equal badges compare equal, so the pop-in plays only
/// when the badge actually changes.
class _SearchBadge {
  const _SearchBadge.flag(String this.countryCode) : religionIcon = null;
  const _SearchBadge.religion(IconData this.religionIcon) : countryCode = null;

  final String? countryCode;
  final IconData? religionIcon;

  Widget build() => switch (this) {
    _SearchBadge(:final countryCode?) => CountryFlag(
      code: countryCode,
      height: 14,
    ),
    _SearchBadge(:final religionIcon?) => Icon(religionIcon, size: 16),
    _ => const SizedBox.shrink(),
  };

  @override
  bool operator ==(Object other) =>
      other is _SearchBadge &&
      other.countryCode == countryCode &&
      other.religionIcon == religionIcon;

  @override
  int get hashCode => Object.hash(countryCode, religionIcon);
}

/// The search box's controller. Each of [badges] is drawn inline right
/// after the character at its offset — a flag after each country name.
/// They're only drawn, never part of the text, so editing, copying and the
/// search itself are unaffected.
///
/// A badge rides along with the character before it, drawn together as one
/// inline widget that stands in for that character. The text and what's
/// drawn then stay the same length, so a cursor after the name sits after
/// the badge rather than between the name and the badge.
class _CountryFlagSearchController extends TextEditingController {
  List<(int, _SearchBadge)> badges = const [];

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final value = text;
    // Only after a plain character; a surrogate pair (an emoji, say) is two
    // code units and would throw the lengths out.
    bool drawable(int end) {
      if (end <= 0 || end > value.length) return false;
      final unit = value.codeUnitAt(end - 1);
      return unit < 0xD800 || unit > 0xDFFF;
    }

    final usable = [
      for (final b in badges)
        if (drawable(b.$1)) b,
    ]..sort((x, y) => x.$1.compareTo(y.$1));
    if (usable.isEmpty) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    final children = <InlineSpan>[];
    var from = 0;
    for (final (end, badge) in usable) {
      if (end - 1 < from) continue;
      if (end - 1 > from) {
        children.add(TextSpan(text: value.substring(from, end - 1)));
      }
      children.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value.substring(end - 1, end), style: style),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: AppSpacing.xs),
                child: _PopIn(key: ValueKey(badge), child: badge.build()),
              ),
            ],
          ),
        ),
      );
      from = end;
    }
    if (from < value.length) {
      children.add(TextSpan(text: value.substring(from)));
    }
    return TextSpan(style: style, children: children);
  }
}

/// Scales and fades [child] in when it first appears.
class _PopIn extends StatelessWidget {
  const _PopIn({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Collapsible.duration,
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.scale(scale: t, child: child),
      ),
      child: child,
    );
  }
}

/// The line under the filter menu that sets it apart from the list. It grows
/// out from the middle as the menu opens and shrinks away as it closes, and
/// takes no room while the menu is shut.
class _MenuEdge extends StatelessWidget {
  const _MenuEdge({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outlineVariant;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: visible ? 1 : 0),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : Collapsible.duration,
      curve: Curves.easeInOutCubic,
      builder: (context, t, _) => Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.lg * t),
        child: t == 0
            ? const SizedBox.shrink()
            : Center(
                child: FractionallySizedBox(
                  widthFactor: t,
                  child: Container(height: 1, color: color),
                ),
              ),
      ),
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

import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../components/buttons/action_button.dart';
import '../../components/cards/people_group_list_card.dart';
import '../../components/inputs/search_field.dart';
import '../../components/widgets/people_groups_list_skeleton.dart';
import '../../models/people_group.dart';
import '../../services/locale_controller.dart';
import '../../services/people_groups_service.dart';
import '../../services/select_people_group_flow.dart';
import '../../services/selected_people_group_controller.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PeopleGroup> _filter(List<PeopleGroup> groups) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return groups;
    return groups.where((g) => g.name.toLowerCase().contains(q)).toList();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.lg,
      children: [
        Row(
          spacing: AppSpacing.md,
          children: [
            Expanded(
              child: SearchField(
                hint: AppLocalizations.of(context)!.searchPeopleGroups,
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                onClear: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              ),
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

  Widget _buildList(BuildContext context, List<PeopleGroup> groups) {
    final filtered = _filter(groups);
    return ValueListenableBuilder<SelectedPeopleGroup?>(
      valueListenable: selectedPeopleGroupController,
      builder: (context, selected, _) {
        // The results count scrolls with the list (it is the first
        // entry) so only the search field stays fixed above it —
        // this keeps the fixed header small at large font scales.
        return ListView.separated(
          padding: EdgeInsets.only(bottom: widget.listBottomPadding),
          itemCount: filtered.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
          itemBuilder: (context, i) {
            if (i == 0) {
              return HyphenatedText(
                AppLocalizations.of(context)!.nPeopleGroups(filtered.length),
                style: AppTypography.caption,
              );
            }
            final g = filtered[i - 1];
            return PeopleGroupListCard(
              name: g.name,
              country: g.countryLabel ?? '',
              imageUrl: g.imageUrl,
              isSelected: selected?.slug == g.slug,
              onSelect: () {
                final cb = widget.onSelect;
                if (cb != null) {
                  cb(g);
                } else {
                  showSelectPeopleGroupConfirmation(
                    context,
                    slug: g.slug,
                    name: g.name,
                    imageUrl: g.imageUrl,
                  );
                }
              },
              onDetails: () => _openDetails(g),
            );
          },
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

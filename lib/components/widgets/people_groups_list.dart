import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/theme/app_colors.dart';
import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';

import 'package:flutter/material.dart';

import '../../components/buttons/action_button.dart';
import '../../components/cards/people_group_list_card.dart';
import '../../components/inputs/search_field.dart';
import '../../models/people_group.dart';
import '../../services/people_groups_service.dart';
import '../../services/selected_people_group_controller.dart';
import '../../theme/app_spacing.dart';
import '../../screens/people_group_details_screen.dart';

class PeopleGroupsList extends StatefulWidget {
  const PeopleGroupsList({super.key});

  @override
  State<PeopleGroupsList> createState() => _PeopleGroupsListState();
}

class _PeopleGroupsListState extends State<PeopleGroupsList> {
  late Future<List<PeopleGroup>> _future;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = fetchPeopleGroups();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() => _future = fetchPeopleGroups());
  }

  List<PeopleGroup> _filter(List<PeopleGroup> groups) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return groups;
    return groups.where((g) => g.name.toLowerCase().contains(q)).toList();
  }

  void _openDetails(PeopleGroup group) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PeopleGroupDetailsScreen(slug: group.slug),
      ),
    );
  }

  Future<void> _onSelectPressed(PeopleGroup group) async {
    final l10n = AppLocalizations.of(context)!;
    final current = selectedPeopleGroupController.value;
    if (current?.slug == group.slug) return;

    final message = current == null
        ? l10n.selectPeopleGroupConfirm
        : l10n.switchPeopleGroupConfirm(current.name, group.name);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(
          message,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.onSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xxxl,
          vertical: AppSpacing.xxl,
        ),
        backgroundColor: AppColors.secondary,
        actions: [
          Row(
            spacing: AppSpacing.xxl,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ActionButton(
                label: l10n.no,
                onPressed: () => Navigator.of(ctx).pop(false),
                color: ActionButtonColor.white,
              ),
              ActionButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                label: l10n.yes,
                color: ActionButtonColor.secondaryLight,
                isOutlined: true,
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await setSelectedPeopleGroup(
        SelectedPeopleGroup(slug: group.slug, name: group.name),
      );
    }
  }

  void _onScanQr() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('QR scan — coming soon')));
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
            ActionButton.icon(
              icon: const Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: 32,
              ),
              onPressed: _onScanQr,
            ),
          ],
        ),
        Expanded(
          child: FutureBuilder<List<PeopleGroup>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _ErrorView(
                  message: AppLocalizations.of(
                    context,
                  )!.couldNotLoadPeopleGroupsMessage,
                  onRetry: _reload,
                );
              }
              final filtered = _filter(snapshot.data ?? const []);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.lg,
                children: [
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.nPeopleGroups(filtered.length),
                    style: AppTypography.caption,
                  ),
                  Expanded(
                    child: ValueListenableBuilder<SelectedPeopleGroup?>(
                      valueListenable: selectedPeopleGroupController,
                      builder: (context, selected, _) {
                        return ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.lg),
                          itemBuilder: (context, i) {
                            final g = filtered[i];
                            return PeopleGroupListCard(
                              name: g.name,
                              imageUrl: g.imageUrl,
                              isSelected: selected?.slug == g.slug,
                              onSelect: () => _onSelectPressed(g),
                              onDetails: () => _openDetails(g),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.lg,
        children: [
          Text(message, textAlign: TextAlign.center),
          ActionButton(
            label: AppLocalizations.of(context)!.retry,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

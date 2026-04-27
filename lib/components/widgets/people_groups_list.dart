import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:flutter/material.dart';

import '../../components/buttons/action_button.dart';
import '../../components/cards/people_group_list_card.dart';
import '../../components/inputs/search_field.dart';
import '../../layouts/page_scaffold.dart';
import '../../models/people_group.dart';
import '../../services/people_groups_service.dart';
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

  void _prayFor(PeopleGroup group) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selecting ${group.name}… (coming soon)')),
    );
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
                hint: 'Search people groups',
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
                  message: 'Could not load people groups.',
                  onRetry: _reload,
                );
              }
              final filtered = _filter(snapshot.data ?? const []);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.lg,
                children: [
                  Text(
                    '${filtered.length} people groups',
                    style: AppTypography.caption,
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (context, i) {
                        final g = filtered[i];
                        return PeopleGroupListCard(
                          name: g.name,
                          imageUrl: g.imageUrl,
                          onPray: () => _prayFor(g),
                          onDetails: () => _openDetails(g),
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
          ActionButton(label: 'Retry', onPressed: onRetry),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/buttons/action_button.dart';
import '../components/map/people_group_map_view.dart';
import '../components/misc/background_image_container.dart';
import '../components/nav/details_nav_bar.dart';
import '../components/nav/root_pop_scope.dart';
import '../l10n/app_localizations.dart';
import '../models/people_group.dart';
import '../services/people_group_locations.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Where one people group sits in the world, among every other people group.
///
/// Opened from the map button on a home people-group card. The pins come from
/// the UUPG list the app already caches on disk, so in the normal case this
/// screen makes no request at all — see `people_group_locations.dart`.
class PeopleGroupMapScreen extends StatefulWidget {
  const PeopleGroupMapScreen({super.key, required this.slug});

  final String slug;

  @override
  State<PeopleGroupMapScreen> createState() => _PeopleGroupMapScreenState();
}

class _PeopleGroupMapScreenState extends State<PeopleGroupMapScreen> {
  late Future<List<PeopleGroup>> _groups;

  @override
  void initState() {
    super.initState();
    _groups = loadPeopleGroupLocations();
  }

  void _retry() {
    setState(() => _groups = loadPeopleGroupLocations());
  }

  void _openProfile(PeopleGroup group) {
    context.push('/people-groups/${group.slug}');
  }

  /// Praying is pushed on top of the map rather than replacing it, so backing
  /// out returns to the same view of the same region.
  void _openPrayer(PeopleGroup group) {
    context.push(
      '/people-groups/${group.slug}/pray',
      extra: {'name': group.name},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return RootPopScope(
      child: FutureBuilder<List<PeopleGroup>>(
        future: _groups,
        builder: (context, snapshot) {
          final focus = snapshot.data
              ?.where((g) => g.slug == widget.slug)
              .firstOrNull;
          return BackgroundImageContainer(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: DetailsNavBar(
                context: context,
                // Falls back to the generic title until the list resolves and
                // the group's own name is known.
                title: focus?.name ?? l.peopleGroup,
                onBack: () => safeBack(context),
              ),
              body: _body(context, snapshot, focus),
            ),
          );
        },
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AsyncSnapshot<List<PeopleGroup>> snapshot,
    PeopleGroup? focus,
  ) {
    final l = AppLocalizations.of(context)!;
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    // A group that isn't in the list, or a list that failed to load, are the
    // same thing from here: there is no map to draw. The home card hides its
    // map button whenever the list is unavailable, so this is the narrow case
    // of the cache expiring between the card being drawn and the map opening.
    if (snapshot.hasError || focus == null) {
      return _ErrorView(message: l.couldNotLoadMapMessage, onRetry: _retry);
    }
    return PeopleGroupMapView(
      focus: focus,
      groups: snapshot.data!,
      onPray: _openPrayer,
      onProfile: _openProfile,
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
          spacing: AppSpacing.lg,
          children: [
            Text(
              message,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            ActionButton(
              label: AppLocalizations.of(context)!.retry,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

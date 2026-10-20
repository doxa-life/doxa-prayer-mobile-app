import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/buttons/action_button.dart';
import '../components/map/people_group_map_view.dart';
import '../components/misc/background_image_container.dart';
import '../components/nav/details_nav_bar.dart';
import '../components/nav/root_pop_scope.dart';
import '../components/nav/sheet_page.dart';
import '../l10n/app_localizations.dart';
import '../models/people_group.dart';
import '../services/map_config.dart';
import '../services/people_group_locations.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Where one people group sits in the world, shown on its own — or, with no
/// [slug], every people group at once.
///
/// Opened for one group from the View on Map button on its profile, and
/// without one from the home screen's own map button and the Search tab's map
/// icon (see [openOverviewMap]). The pins come from
/// the UUPG list the app already caches on disk, so in the normal case this
/// screen makes no request at all — see `people_group_locations.dart`.
/// Opens the map of every people group. A build with no Mapbox token says why
/// rather than opening a map that can only ever show grey squares — the same
/// answer the carousel gives.
void openOverviewMap(BuildContext context) {
  if (!MapConfig.isConfigured) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.mapNotConfigured)),
      );
    return;
  }
  context.push('/map');
}

class PeopleGroupMapScreen extends StatefulWidget {
  const PeopleGroupMapScreen({super.key, this.slug});

  /// The group to open on, or null for the overview of every group.
  final String? slug;

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

  /// The map of one group is opened from that group's profile, so its
  /// profile is already just behind: going back to it beats stacking a
  /// second copy on top. A deep link straight to the map has nothing behind
  /// it, and opens the profile as usual.
  void _openProfile(PeopleGroup group) {
    if (widget.slug == group.slug && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    pushSheet(context, '/people-groups/${group.slug}');
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
        // Nearly always loaded already (the home cards and the Search tab
        // read the same list), so the map is drawn in the first frame rather
        // than after a frame of spinner — which rebuilt the whole map in the
        // middle of the page sliding in.
        initialData: peopleGroupLocationsController.value.isEmpty
            ? null
            : peopleGroupLocationsController.value,
        builder: (context, snapshot) {
          final slug = widget.slug;
          final focus = slug == null
              ? null
              : snapshot.data?.where((g) => g.slug == slug).firstOrNull;
          return BackgroundImageContainer(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: DetailsNavBar(
                context: context,
                // For one group, falls back to the generic title until the
                // list resolves and the group's own name is known.
                title: widget.slug == null
                    ? l.map
                    : focus?.name ?? l.peopleGroup,
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
    if (snapshot.connectionState == ConnectionState.waiting &&
        !snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    // A group that isn't in the list, or a list that failed to load, are the
    // same thing from here: there is no map to draw. The profile hides its
    // map button for a group the list has no location for, so this is the
    // narrow case of the cache expiring between the profile being drawn and
    // the map opening.
    //
    // The overview has no group to miss, but an empty list is still no map:
    // a failed fetch on a cold cache resolves to nothing rather than an error.
    if (snapshot.hasError ||
        (widget.slug != null && focus == null) ||
        (snapshot.data?.isEmpty ?? true)) {
      return _ErrorView(message: l.couldNotLoadMapMessage, onRetry: _retry);
    }
    return PeopleGroupMapView(
      focus: focus,
      // One group's map shows that group and no other.
      groups: focus != null ? [focus] : snapshot.data!,
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

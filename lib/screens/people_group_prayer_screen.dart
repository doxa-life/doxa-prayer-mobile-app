import 'package:flutter/material.dart';

import '../components/misc/background_image_container.dart';
import '../components/nav/details_nav_bar.dart';
import '../components/nav/root_pop_scope.dart';
import '../components/prayer_content/prayer_session_view.dart';
import '../services/locale_controller.dart';

/// Prayer content for one people group, pushed on top of whatever opened it.
///
/// Used by the people-group map: praying for a neighbouring group from a pin's
/// card shouldn't cost the user the map they were exploring, so this is a
/// pushed route with a back arrow rather than a jump to the Pray tab. It also
/// works for a group the user hasn't subscribed to — prayer history is keyed by
/// slug, not by subscription.
class PeopleGroupPrayerScreen extends StatelessWidget {
  const PeopleGroupPrayerScreen({
    super.key,
    required this.slug,
    required this.name,
  });

  final String slug;

  /// Shown in the nav bar. Passed in rather than fetched: whoever pushed this
  /// screen already knows the name, and the prayer content below fetches its
  /// own data.
  final String name;

  @override
  Widget build(BuildContext context) {
    // A root-level route, so it can be the only page on the stack if its URL is
    // opened cold — safeBack and RootPopScope both handle that.
    return RootPopScope(
      child: BackgroundImageContainer(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: DetailsNavBar(
            context: context,
            title: name,
            onBack: () => safeBack(context),
          ),
          body: ValueListenableBuilder<Locale>(
            valueListenable: localeController,
            builder: (context, locale, _) {
              return PrayerSessionView(
                key: ValueKey('$slug-${locale.languageCode}'),
                slug: slug,
                language: locale.languageCode,
                isActive: () => true,
              );
            },
          ),
        ),
      ),
    );
  }
}

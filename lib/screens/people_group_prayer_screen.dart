import 'package:flutter/material.dart';

import '../components/misc/background_image_container.dart';
import '../components/nav/details_nav_bar.dart';
import '../components/nav/root_pop_scope.dart';
import '../components/prayer_content/prayer_session_view.dart';
import '../services/locale_controller.dart';

/// Prayer content for one people group, pushed on top of whatever opened it.
///
/// The Saved prayers list opens its prayers here, on the day that was saved.
/// It works for a group the user hasn't subscribed to — prayer history is
/// keyed by slug, not by subscription.
class PeopleGroupPrayerScreen extends StatelessWidget {
  const PeopleGroupPrayerScreen({
    super.key,
    required this.slug,
    required this.name,
    this.initialDate,
  });

  final String slug;

  /// The day to open on, when not today — a prayer reopened from the Saved
  /// prayers list.
  final DateTime? initialDate;

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
                initialDate: initialDate,
              );
            },
          ),
        ),
      ),
    );
  }
}

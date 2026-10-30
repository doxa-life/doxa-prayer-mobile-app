import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../models/prayer_content.dart';
import '../../theme/app_spacing.dart';
import 'people_group_intro_view.dart';
import 'people_group_of_the_day_view.dart';
import 'prayer_doc_view.dart';

/// Renders a full `PrayerContentResponse` as a vertical stack of
/// content blocks: people-group introductions and static rich-text docs.
///
/// The People Group of the Day sits between the third part of the prayer and
/// the fourth — each part being a doc that ends with "Pause & Pray" — or after
/// the last part, when there are fewer than four.
///
/// Built to change in place. When the response is swapped for another — a
/// new day, a new group — each block that is the same as before stays exactly
/// as it is, and each one that differs fades out and its replacement fades in,
/// top block first, so the new prayer reads as arriving from the top down.
/// Height changes glide rather than jump.
class PrayerContentView extends StatelessWidget {
  const PrayerContentView({
    super.key,
    required this.response,
    this.showIntro = true,
  });

  final PrayerContentResponse response;

  /// Whether to show the people-group introduction ("Pray for the …" and the
  /// group's photo). Off on the Pray tab, where the group's card above the
  /// prayer already says who it is for.
  final bool showIntro;

  /// The space between sections of the prayer: well over the
  /// [AppSpacing.xxl] between paragraphs inside a section, so where one ends
  /// and the next begins is plain.
  static const double _sectionGap = AppSpacing.xxxl * 1.3;

  /// How many parts of the prayer come before the People Group of the Day.
  static const int _partsBeforeOfTheDay = 3;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    void add(Widget widget, String key) {
      final order = children.length;
      children.add(
        // Keyed by position, so the block in each slot changes in place.
        BlockSwap(
          key: ValueKey('slot-$order'),
          order: order,
          child: KeyedSubtree(key: ValueKey(key), child: widget),
        ),
      );
    }

    final ofTheDay = response.content
        .where(
          (b) =>
              b.type == PrayerContentBlockType.peopleGroupOfTheDay &&
              b.peopleGroupData != null,
        )
        .firstOrNull;
    // Changes only when the group of the day does.
    void addOfTheDay() => add(
      PeopleGroupOfTheDayView(
        name: ofTheDay!.title,
        data: ofTheDay.peopleGroupData!,
        heading: AppLocalizations.of(context)!.peopleGroupOfTheDay,
      ),
      'of-the-day-${ofTheDay.title}',
    );

    var parts = 0;
    var ofTheDayPlaced = ofTheDay == null;
    for (final block in response.content) {
      final widget = _buildBlock(context, block);
      if (widget == null) continue;
      add(widget, '${block.type.name}-${block.id}-${block.title}');
      if (widget is PrayerDocView) parts++;
      if (!ofTheDayPlaced && parts == _partsBeforeOfTheDay) {
        addOfTheDay();
        ofTheDayPlaced = true;
      }
    }
    if (!ofTheDayPlaced) addOfTheDay();
    return AnimatedSize(
      duration: BlockSwap.resize,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: _sectionGap,
        children: children,
      ),
    );
  }

  Widget? _buildBlock(BuildContext context, PrayerContentBlock block) {
    switch (block.type) {
      case PrayerContentBlockType.peopleGroup:
        if (!showIntro) return null;
        final data = block.peopleGroupData;
        if (data == null) return null;
        return PeopleGroupIntroView(name: block.title, data: data);
      // Placed between the parts of the prayer — see [build].
      case PrayerContentBlockType.peopleGroupOfTheDay:
        return null;
      case PrayerContentBlockType.static:
        final doc = block.contentJson;
        if (doc == null) return null;
        return PrayerDocView(doc: doc);
      case PrayerContentBlockType.dayInTheLife:
        final doc = block.contentJson;
        if (doc == null) return null;
        return PrayerDocView(
          doc: doc,
          title: AppLocalizations.of(context)!.dayInTheLifeTitle,
        );
      case PrayerContentBlockType.unknown:
        return null;
    }
  }
}

/// One slot of a page that changes in place.
///
/// [child] must carry a key saying what it shows. While that key stays the
/// same nothing happens — the block is not rebuilt, its photos not reloaded.
/// When it changes, the old block fades out quickly and the new one fades in
/// just after it, never both readable at once (two layers of text a few
/// pixels apart read as a shudder). [order] delays the fade-in a little per
/// slot, so a page of changes arrives from the top down. A slot that first
/// appears fades in the same way.
class BlockSwap extends StatelessWidget {
  const BlockSwap({super.key, required this.child, this.order = 0});

  final Widget child;
  final int order;

  /// How long the old block takes to fade out.
  static const Duration fadeOut = Duration(milliseconds: 110);

  /// How long the new block takes to fade in, once its turn comes.
  static const Duration fadeIn = Duration(milliseconds: 260);

  /// The extra wait for each slot further down the page.
  static const Duration step = Duration(milliseconds: 50);

  /// How long a change of height takes.
  static const Duration resize = Duration(milliseconds: 260);

  @override
  Widget build(BuildContext context) {
    final delay = fadeOut + step * order.clamp(0, 6);
    final total = delay + fadeIn;
    final curve = Interval(
      delay.inMicroseconds / total.inMicroseconds,
      1,
      curve: Curves.easeOut,
    );
    return TweenAnimationBuilder<double>(
      // Runs once, when the slot first appears: 0 to 1, then never again.
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: curve,
      builder: (context, shown, swap) => Opacity(opacity: shown, child: swap),
      child: AnimatedSize(
        duration: resize,
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: total,
          reverseDuration: fadeOut,
          switchInCurve: curve,
          switchOutCurve: Curves.easeIn,
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.topCenter,
            children: [...previous, ?current],
          ),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: RepaintBoundary(child: child),
          ),
          child: child,
        ),
      ),
    );
  }
}

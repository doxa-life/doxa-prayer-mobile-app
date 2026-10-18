import 'package:doxa_prayer_mobile_app/components/misc/skeleton_box.dart';
import 'package:doxa_prayer_mobile_app/components/prayer_content/prayer_content_skeleton.dart';
import 'package:doxa_prayer_mobile_app/components/widgets/people_group_details_skeleton.dart';
import 'package:doxa_prayer_mobile_app/components/widgets/people_groups_list_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_at_scale.dart';

/// Reads the colour the skeleton is currently painting.
Color? _boxColor(WidgetTester tester) {
  final decorated = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(SkeletonBox).first,
      matching: find.byType(DecoratedBox),
    ),
  );
  return (decorated.decoration as BoxDecoration).color;
}

void main() {
  testWidgets('SkeletonBox pulses between two tones', (tester) async {
    await pumpAtScale(tester, const SkeletonBox(width: 96, height: 96));

    final start = _boxColor(tester);
    await tester.pump(const Duration(milliseconds: 450));
    expect(_boxColor(tester), isNot(start));

    // A repeating animation never settles, so end the test on a fixed pump.
    await tester.pump(const Duration(milliseconds: 450));
  });

  testWidgets('SkeletonBox holds a steady tone when animations are disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: SkeletonBox(width: 96, height: 96),
        ),
      ),
    );

    final start = _boxColor(tester);
    await tester.pump(const Duration(milliseconds: 450));
    expect(_boxColor(tester), start);
  });

  // The skeletons stand in for content on small screens at large OS font
  // sizes, where a fixed-height placeholder is the easiest thing to overflow.
  for (final entry in <String, Widget>{
    'PeopleGroupsListSkeleton': const PeopleGroupsListSkeleton(),
    // Shown inside the Pray screen's scroll view, so tested inside one.
    'PrayerContentSkeleton': const SingleChildScrollView(
      child: PrayerContentSkeleton(),
    ),
    'PeopleGroupDetailsSkeleton': const PeopleGroupDetailsSkeleton(),
  }.entries) {
    testWidgets('${entry.key} lays out without overflow at 3x', (tester) async {
      await pumpAtScale(
        tester,
        entry.value,
        scale: 3.0,
        viewport: const Size(320, 690),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(SkeletonBox), findsWidgets);
      await tester.pump(const Duration(milliseconds: 450));
    });
  }
}

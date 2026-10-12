import 'package:doxa_prayer_mobile_app/components/inputs/filter_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_at_scale.dart';

// A section with a body starts closed, animates open on tap (the body is
// mid-way in height partway through), and drops the body from the tree once
// closed again. Its modified mark pops in without moving the title.
void main() {
  Widget section({required bool expanded, required VoidCallback onToggle}) =>
      SingleChildScrollView(
        child: FilterSection(
          title: 'Population',
          expanded: expanded,
          onTap: onToggle,
          child: const SizedBox(height: 200, child: Text('Body')),
        ),
      );

  testWidgets('opens and closes smoothly', (tester) async {
    var expanded = false;
    late StateSetter setOuter;
    await pumpAtScale(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          setOuter = setState;
          return section(
            expanded: expanded,
            onToggle: () => setOuter(() => expanded = !expanded),
          );
        },
      ),
      scale: 1.0,
    );

    expect(find.text('Body'), findsNothing);

    await tester.tap(find.text('Population'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final midHeight = tester.getSize(find.byType(FilterSection)).height;
    await tester.pumpAndSettle();
    final openHeight = tester.getSize(find.byType(FilterSection)).height;
    expect(find.text('Body'), findsOneWidget);
    expect(midHeight, lessThan(openHeight));

    await tester.tap(find.text('Population'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Body'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Body'), findsNothing);
  });

  testWidgets('header does not overflow at 3x', (tester) async {
    await pumpAtScale(
      tester,
      section(expanded: true, onToggle: () {}),
      scale: 3.0,
      viewport: const Size(320, 690),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('the modified mark appears without moving the title', (
    tester,
  ) async {
    var active = false;
    late StateSetter setOuter;
    await pumpAtScale(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          setOuter = setState;
          return FilterSection(
            title: 'Country',
            isActive: active,
            onTap: () {},
          );
        },
      ),
      scale: 1.0,
    );
    final before = tester.getTopLeft(find.text('Country'));
    setOuter(() => active = true);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Country')), before);
    final mark = tester.widget<AnimatedOpacity>(
      find.ancestor(
        of: find.byIcon(Icons.check_circle),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(mark.opacity, 1);
  });
}

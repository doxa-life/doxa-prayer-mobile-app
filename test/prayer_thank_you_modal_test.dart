import 'package:doxa_prayer_mobile_app/components/prayer_content/prayer_thank_you_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_at_scale.dart';

void main() {
  testWidgets('scrolls (no overflow) on a small screen at 3x font scale', (
    tester,
  ) async {
    await pumpAtScale(
      tester,
      const Center(child: PrayerThankYouModal()),
      scale: 3.0,
      viewport: const Size(320, 480),
    );

    // No RenderFlex overflow at large font scales.
    expect(tester.takeException(), isNull);

    // The close button is visible at the top without scrolling...
    expect(find.byIcon(Icons.close).hitTestable(), findsOneWidget);

    // ...and the bottom Home button can be scrolled into view (ActionButton
    // uppercases its label).
    final homeButton = find.text('HOME');
    await tester.scrollUntilVisible(homeButton, 100);
    expect(homeButton.hitTestable(), findsOneWidget);
  });
}

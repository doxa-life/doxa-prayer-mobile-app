import 'package:doxa_prayer_mobile_app/components/prayer_content/prayer_thank_you_modal.dart';
import 'package:doxa_prayer_mobile_app/services/thank_you_verse_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_at_scale.dart';

const _verse = ThankYouVerse(
  text: 'Let my prayer be set before You as incense, '
      'The lifting up of my hands as the evening sacrifice.',
  reference: 'Psalm 141:2',
  translation: 'NKJV',
);

void main() {
  testWidgets('scrolls (no overflow) on a small screen at 3x font scale', (
    tester,
  ) async {
    await pumpAtScale(
      tester,
      const Center(child: PrayerThankYouModal(verse: _verse)),
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

  testWidgets('shows the verse and its reference', (tester) async {
    await pumpAtScale(
      tester,
      const Center(child: PrayerThankYouModal(verse: _verse)),
      scale: 1.0,
    );

    expect(find.text(_verse.reference), findsOneWidget);
    expect(find.textContaining('as the evening sacrifice'), findsOneWidget);
  });

  testWidgets('renders without a verse when the set fails to load', (
    tester,
  ) async {
    await pumpAtScale(
      tester,
      const Center(child: PrayerThankYouModal()),
      scale: 1.0,
    );

    expect(tester.takeException(), isNull);
    // The title and the Home button still carry the modal on their own.
    expect(find.text('HOME'), findsOneWidget);
  });
}

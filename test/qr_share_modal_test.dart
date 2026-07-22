import 'package:doxa_prayer_mobile_app/components/misc/qr_share_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'helpers/pump_at_scale.dart';

void main() {
  testWidgets('scrolls (no overflow) on a small screen at 3x font scale', (
    tester,
  ) async {
    await pumpAtScale(
      tester,
      const Center(
        child: QrShareModal(
          url: 'https://doxa.life/kurds/prayer',
          peopleGroupName: 'Kurds',
        ),
      ),
      scale: 3.0,
      viewport: const Size(320, 480),
    );

    // No RenderFlex overflow at large font scales.
    expect(tester.takeException(), isNull);

    // The QR shrinks below its 240px default so a scannable code fits the
    // short viewport.
    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.size, lessThan(240));

    // The caption below the QR can be scrolled into view.
    final caption = find.textContaining('Kurds');
    await tester.scrollUntilVisible(caption, 100);
    expect(caption, findsOneWidget);
  });
}

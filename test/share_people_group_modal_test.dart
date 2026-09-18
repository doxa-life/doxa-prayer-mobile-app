import 'package:doxa_prayer_mobile_app/components/buttons/action_button.dart';
import 'package:doxa_prayer_mobile_app/components/misc/share_people_group_modal.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
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
      Center(
        child: SharePeopleGroupModal(
          url: 'https://doxa.life/kurds/prayer',
          peopleGroupName: 'Kurds',
          onShareLink: (_) {},
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

  testWidgets('the share button closes the modal and reports its bounds', (
    tester,
  ) async {
    Rect? origin;
    var calls = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showSharePeopleGroupModal(
                context,
                url: 'https://doxa.life/kurds/prayer',
                peopleGroupName: 'Kurds',
                onShareLink: (rect) {
                  origin = rect;
                  calls++;
                },
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(SharePeopleGroupModal), findsOneWidget);

    await tester.tap(find.byType(ActionButton));
    await tester.pumpAndSettle();

    // The modal gets out of the way before the share sheet appears, and hands
    // over where it was so an iPad popover has an anchor.
    expect(find.byType(SharePeopleGroupModal), findsNothing);
    expect(calls, 1);
    expect(origin, isNotNull);
    expect(origin!.isEmpty, isFalse);
  });
}

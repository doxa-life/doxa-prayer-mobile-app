import 'package:doxa_prayer_mobile_app/components/buttons/action_button.dart';
import 'package:doxa_prayer_mobile_app/components/misc/action_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ActionButton uppercases its label, so match against the upper-cased text.
Widget _wrap({required String allowLabel}) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: ActionModal(
        message: 'Allow exact alarms so your reminders arrive on time.',
        actionButtons: [
          ActionButton(
            label: 'Not now',
            onPressed: () {},
            color: ActionButtonColor.white,
          ),
          ActionButton(
            label: allowLabel,
            onPressed: () {},
            color: ActionButtonColor.secondaryLight,
            isOutlined: true,
          ),
        ],
      ),
    ),
  ),
);

void main() {
  testWidgets('lays buttons side by side when the labels fit', (tester) async {
    // Wide viewport: the test font renders each glyph as a full-em square, so
    // labels measure much wider than with real fonts — give the row room to fit.
    tester.view.physicalSize = const Size(600, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(allowLabel: 'Allow'));

    expect(tester.takeException(), isNull);
    // Same vertical centre => on one row.
    final notNow = tester.getCenter(find.text('NOT NOW')).dy;
    final allow = tester.getCenter(find.text('ALLOW')).dy;
    expect(notNow, allow);
  });

  testWidgets('stacks buttons (no overflow) when a label is too long', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(allowLabel: 'Allow exact alarms always'));

    // No RenderFlex overflow was thrown during layout.
    expect(tester.takeException(), isNull);
    // Different vertical centres => stacked, not overflowing off the row.
    final notNow = tester.getCenter(find.text('NOT NOW')).dy;
    final allow = tester.getCenter(find.text('ALLOW EXACT ALARMS ALWAYS')).dy;
    expect(allow, isNot(notNow));
  });
}

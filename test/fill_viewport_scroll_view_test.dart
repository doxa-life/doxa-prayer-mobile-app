import 'package:doxa_prayer_mobile_app/layouts/fill_viewport_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _viewport = Size(360, 690);

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(resizeToAvoidBottomInset: false, body: child),
);

Widget _column({required double contentHeight}) => FillViewportScrollView(
  builder: (context, maxWidth) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(height: contentHeight, child: const Text('content')),
      const Expanded(child: SizedBox.shrink()),
      const SizedBox(key: Key('footer'), height: 48),
    ],
  ),
);

void main() {
  testWidgets('pins the footer to the bottom when content fits', (
    tester,
  ) async {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(_column(contentHeight: 100)));

    expect(tester.takeException(), isNull);
    final footer = tester.getRect(find.byKey(const Key('footer')));
    expect(footer.bottom, _viewport.height);
  });

  testWidgets('scrolls instead of overflowing when content is tall', (
    tester,
  ) async {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(_column(contentHeight: 1200)));

    // No RenderFlex overflow thrown, footer starts below the fold...
    expect(tester.takeException(), isNull);
    final footer = find.byKey(const Key('footer'));
    expect(tester.getRect(footer).top, greaterThan(_viewport.height));

    // ...and can be scrolled into view.
    await tester.ensureVisible(footer);
    await tester.pumpAndSettle();
    expect(
      tester.getRect(footer).bottom,
      lessThanOrEqualTo(_viewport.height),
    );
  });

  testWidgets('adds scroll padding for the keyboard inset', (tester) async {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(_column(contentHeight: 100)));

    // Content fits the viewport, so the only scrollable extent is the
    // keyboard padding — enough to lift the footer above the keyboard.
    final position = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position;
    expect(position.maxScrollExtent, 300);
  });

  testWidgets('padKeyboardInset: false ignores the keyboard inset', (
    tester,
  ) async {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _wrap(
        FillViewportScrollView(
          padKeyboardInset: false,
          builder: (context, maxWidth) => const SizedBox(height: 100),
        ),
      ),
    );

    final position = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position;
    expect(position.maxScrollExtent, 0);
  });
}

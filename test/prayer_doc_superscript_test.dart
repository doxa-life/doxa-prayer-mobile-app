import 'package:doxa_prayer_mobile_app/components/misc/superscript_text.dart';
import 'package:doxa_prayer_mobile_app/components/prayer_content/prayer_doc_view.dart';
import 'package:doxa_prayer_mobile_app/components/prayer_content/prayer_verse_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_at_scale.dart';

/// Verse numbers arrive as a `superscript`-marked text node. They used to be
/// styled with `FontFeature.superscripts()`, which no bundled face implements,
/// so they only shrank and sat on the baseline — reading as subscripts.
Map<String, dynamic> _sup(String text) => {
  'type': 'text',
  'text': text,
  'marks': [
    {'type': 'superscript'},
  ],
};

Map<String, dynamic> _doc(String number) => {
  'type': 'doc',
  'content': [
    {
      'type': 'verse',
      'attrs': {'reference': 'John 3:16', 'translation': 'NIV'},
      'content': [
        {
          'type': 'paragraph',
          'content': [
            _sup(number),
            {
              'type': 'text',
              'text':
                  'For God so loved the world, that he gave his only '
                  'begotten Son, ',
            },
            _sup('17 '),
            {
              'type': 'text',
              'text': 'that whoever believes in Him should not perish.',
            },
          ],
        },
      ],
    },
  ],
};

/// Scrollable so the block still lays out at large text scales.
Widget _view(String number) =>
    SingleChildScrollView(child: PrayerDocView(doc: _doc(number)));

Offset _paintOffset(WidgetTester tester) {
  final transform = tester.widget<Transform>(
    find
        .descendant(
          of: find.byType(SuperscriptText),
          matching: find.byType(Transform),
        )
        .first,
  );
  return Offset(transform.transform[12], transform.transform[13]);
}

RenderParagraph _verseParagraph(WidgetTester tester) =>
    tester.renderObject<RenderParagraph>(
      find
          .descendant(
            of: find.byType(PrayerVerseView),
            matching: find.byType(RichText),
          )
          .first,
    );

/// The heights of every superscript box currently laid out.
List<double> _boxHeights(WidgetTester tester) => tester
    .renderObjectList<RenderBox>(find.byType(SuperscriptText))
    .map((box) => box.size.height)
    .toList();

void main() {
  testWidgets('verse numbers are painted above the baseline', (tester) async {
    await pumpAtScale(tester, _view('16 '), scale: 1.0);

    expect(find.byType(SuperscriptText), findsNWidgets(2));
    final superscript = tester.widget<SuperscriptText>(
      find.byType(SuperscriptText).first,
    );
    // The CMS's separating space is dropped — the gap is the widget's padding.
    expect(superscript.text, '16');
    // Smaller than, and lifted off, the run it sits in.
    final baseSize = PrayerVerseView.textStyle.fontSize!;
    final rendered = tester.widget<Text>(
      find
          .descendant(
            of: find.byType(SuperscriptText),
            matching: find.byType(Text),
          )
          .first,
    );
    expect(rendered.style!.fontSize, lessThan(baseSize));
    expect(_paintOffset(tester).dy, lessThan(0));
  });

  testWidgets('the number is welded to its word by a sub-space gap', (
    tester,
  ) async {
    await pumpAtScale(tester, _view('16 '), scale: 1.0);

    // The word after the number is drawn inside the box, not left in the run.
    final superscript = tester.widget<SuperscriptText>(
      find.byType(SuperscriptText).first,
    );
    expect(superscript.attached, 'For');

    final gap = tester.widget<SizedBox>(
      find
          .descendant(
            of: find.byType(SuperscriptText).first,
            matching: find.byType(SizedBox),
          )
          .first,
    );
    expect(gap.width, greaterThan(0));
    // Poppins' space is about 0.26 em; the point of the knob is to beat that.
    expect(gap.width, lessThan(PrayerVerseView.textStyle.fontSize! * 0.26));
  });

  testWidgets('the verse paragraph keeps only what the box did not claim', (
    tester,
  ) async {
    await pumpAtScale(tester, _view('16 '), scale: 1.0);

    final paragraph = _verseParagraph(tester);
    final plain = paragraph.text.toPlainText(includePlaceholders: true);
    // Each number and its first word are one placeholder; the run picks up
    // again at the space before the second word.
    expect(
      plain,
      '\uFFFC God so loved the world, that he gave his only begotten Son, '
      '\uFFFC whoever believes in Him should not perish.',
    );
  });

  testWidgets('a verse number is never orphaned from its first word', (
    tester,
  ) async {
    // The number and its word share one box, so the only way they could come
    // apart is if that box wrapped internally. Sweep widths — including ones
    // that put the box right on the wrap point — and check it stays one line
    // tall. From 300 up: below that the block's "pause and pray" footer
    // overflows, which is a separate layout concern.
    await pumpAtScale(
      tester,
      _view('16 '),
      scale: 1.0,
      viewport: Size(900, 900),
    );
    final oneLine = _boxHeights(tester);
    expect(oneLine, hasLength(2));

    for (var width = 300.0; width <= 480.0; width += 2) {
      await pumpAtScale(
        tester,
        _view('16 '),
        scale: 1.0,
        viewport: Size(width, 1600),
      );
      expect(
        _boxHeights(tester),
        oneLine,
        reason: 'a verse number split from its word at a width of $width',
      );
    }
  });

  testWidgets('the lift scales with the OS font size', (tester) async {
    // Driven directly rather than through the doc, whose "pause and pray"
    // footer overflows a phone width at 2x — a separate layout concern.
    final superscript = SuperscriptText(
      text: '16',
      baseStyle: PrayerVerseView.textStyle,
    );
    await pumpAtScale(tester, superscript, scale: 1.0);
    final atOne = _paintOffset(tester).dy;

    await pumpAtScale(tester, superscript, scale: 2.0);
    expect(_paintOffset(tester).dy, lessThan(atOne));
  });

  testWidgets('an all-whitespace superscript is left as plain text', (
    tester,
  ) async {
    await pumpAtScale(tester, _view('  '), scale: 1.0);
    // Only the second, real verse number survives.
    expect(find.byType(SuperscriptText), findsOneWidget);
    expect(
      tester.widget<SuperscriptText>(find.byType(SuperscriptText)).text,
      '17',
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hyphenatorx/hyphenatorx.dart';

import '../../services/glossary.dart';
import '../../services/hyphenation_service.dart';
import 'glossary_text.dart';

/// A drop-in [Text] replacement that breaks over-long words with a visible
/// hyphen instead of mid-character.
///
/// At large accessibility font scales and display zoom a single word can be
/// wider than its line; Flutter then splits it at an arbitrary character with no
/// marker, so "Congregationalism" reads as "Congregat" / "ionalism". This
/// measures the text against the width it was actually given and inserts real
/// hyphens at syllable boundaries — see
/// [hyphenateForWidth] in `services/hyphenation_service.dart`.
///
/// Falls back to a plain [Text], unchanged, whenever hyphenation cannot apply:
/// a language with no patterns (Arabic, and anything unmapped), patterns still
/// loading, unbounded width, or text whose every word already fits.
///
/// One of the app's sentences that mentions a glossary term is handed to
/// [GlossaryText] instead, so the term can be tapped for its definition —
/// which strings those are was settled when the app was built (see
/// `services/glossary.dart`), so this costs one map lookup. [glossary] false
/// opts out.
class HyphenatedText extends StatelessWidget {
  const HyphenatedText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.semanticsLabel,
    this.glossary = true,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  /// Spoken instead of the rendered text. Defaults to [data], so screen readers
  /// always get the unbroken words rather than the hyphenated line breaks.
  final String? semanticsLabel;

  /// Whether glossary terms in [data] link to their definitions.
  final bool glossary;

  @override
  Widget build(BuildContext context) {
    if (glossary &&
        semanticsLabel == null &&
        Localizations.maybeLocaleOf(context) != null &&
        glossarySpansOf(context, data) != null) {
      return GlossaryText(
        data,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
      );
    }
    final locale = Localizations.maybeLocaleOf(context);
    final hyphenator = locale == null ? null : hyphenatorFor(locale);
    if (hyphenator == null || data.isEmpty) return _text(data);

    final resolved = _resolvedStyle(context);
    // The rendered Text scales the font size itself, so measure with it already
    // applied.
    final measureStyle = resolved.copyWith(
      fontSize: MediaQuery.textScalerOf(
        context,
      ).scale(resolved.fontSize ?? _fallbackFontSize),
    );
    final textDirection = Directionality.of(context);

    return _Measurable(
      data: data,
      style: measureStyle,
      hyphenator: hyphenator,
      localeCode: locale!.languageCode,
      textDirection: textDirection,
      maxLines: maxLines,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.hasBoundedWidth) return _text(data);
          final wrapped = hyphenateForWidth(
            text: data,
            style: measureStyle,
            maxWidth: constraints.maxWidth,
            hyphenator: hyphenator,
            localeCode: locale.languageCode,
            textDirection: textDirection,
          );
          if (wrapped == data) return _text(data);
          return _text(wrapped, semantics: semanticsLabel ?? data);
        },
      ),
    );
  }

  /// Mirrors [Text]'s own style resolution so measurement matches rendering.
  TextStyle _resolvedStyle(BuildContext context) {
    final style = this.style;
    if (style != null && !style.inherit) return style;
    return DefaultTextStyle.of(context).style.merge(style);
  }

  Widget _text(String text, {String? semantics}) => Text(
    text,
    style: style,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    softWrap: softWrap,
    semanticsLabel: semantics ?? semanticsLabel,
  );

  /// Flutter's own default when no style in scope sets a size.
  static const double _fallbackFontSize = 14;
}

/// Answers size questions on behalf of the [LayoutBuilder] beneath it.
///
/// A [LayoutBuilder] cannot report intrinsic dimensions or a dry layout — it
/// would have to run its build callback speculatively — and it throws when
/// asked. Plenty of stock widgets ask: [IntrinsicHeight] and [IntrinsicWidth]
/// directly, and `Chip` calls `getDryLayout` on its label. Without this shim,
/// putting a [HyphenatedText] inside any of them crashes in debug and mis-sizes
/// in release.
///
/// So this measures the text itself with a throwaway [TextPainter] — no
/// speculative builds, no mutation — and lets layout and painting proceed
/// normally through the child.
class _Measurable extends SingleChildRenderObjectWidget {
  const _Measurable({
    required this.data,
    required this.style,
    required this.hyphenator,
    required this.localeCode,
    required this.textDirection,
    required this.maxLines,
    required super.child,
  });

  final String data;

  /// Already text-scaled, matching what the child renders.
  final TextStyle style;
  final Hyphenator hyphenator;
  final String localeCode;
  final TextDirection textDirection;
  final int? maxLines;

  @override
  _RenderMeasurable createRenderObject(BuildContext context) =>
      _RenderMeasurable(
        data: data,
        style: style,
        hyphenator: hyphenator,
        localeCode: localeCode,
        textDirection: textDirection,
        maxLines: maxLines,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMeasurable renderObject,
  ) {
    renderObject
      ..data = data
      ..style = style
      ..hyphenator = hyphenator
      ..localeCode = localeCode
      ..textDirection = textDirection
      ..maxLines = maxLines;
  }
}

class _RenderMeasurable extends RenderProxyBox {
  _RenderMeasurable({
    required String data,
    required TextStyle style,
    required Hyphenator hyphenator,
    required String localeCode,
    required TextDirection textDirection,
    required int? maxLines,
  }) : _data = data,
       _style = style,
       _hyphenator = hyphenator,
       _localeCode = localeCode,
       _textDirection = textDirection,
       _maxLines = maxLines;

  String _data;
  set data(String value) {
    if (_data == value) return;
    _data = value;
    markNeedsLayout();
  }

  TextStyle _style;
  set style(TextStyle value) {
    if (_style == value) return;
    _style = value;
    markNeedsLayout();
  }

  Hyphenator _hyphenator;
  set hyphenator(Hyphenator value) {
    if (_hyphenator == value) return;
    _hyphenator = value;
    markNeedsLayout();
  }

  String _localeCode;
  set localeCode(String value) {
    if (_localeCode == value) return;
    _localeCode = value;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  int? _maxLines;
  set maxLines(int? value) {
    if (_maxLines == value) return;
    _maxLines = value;
    markNeedsLayout();
  }

  /// Lays the text out exactly as the child will, at [maxWidth].
  TextPainter _paint(double maxWidth) {
    final text = maxWidth.isFinite
        ? hyphenateForWidth(
            text: _data,
            style: _style,
            maxWidth: maxWidth,
            hyphenator: _hyphenator,
            localeCode: _localeCode,
            textDirection: _textDirection,
          )
        : _data;
    return TextPainter(
      text: TextSpan(text: text, style: _style),
      textDirection: _textDirection,
      maxLines: _maxLines,
    )..layout(maxWidth: maxWidth);
  }

  T _measure<T>(double maxWidth, T Function(TextPainter) read) {
    final painter = _paint(maxWidth);
    final value = read(painter);
    painter.dispose();
    return value;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      constraints.constrain(_measure(constraints.maxWidth, (p) => p.size));

  // Widths match a plain Text's: the narrowest is one word, the widest is the
  // whole string unbroken. Hyphenation only ever reduces the width needed, so
  // reporting the unhyphenated bounds keeps sizing identical to before.
  @override
  double computeMinIntrinsicWidth(double height) =>
      _measure(double.infinity, (p) => p.minIntrinsicWidth);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _measure(double.infinity, (p) => p.maxIntrinsicWidth);

  // Heights must account for hyphenation: breaking a word adds a line.
  @override
  double computeMinIntrinsicHeight(double width) =>
      _measure(width, (p) => p.height);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _measure(width, (p) => p.height);
}

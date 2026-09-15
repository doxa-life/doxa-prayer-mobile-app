import 'package:flutter/material.dart';

/// The heart used for the people groups the user prays for.
///
/// The same glyph [SelectedPill] shows on the pin card — a hand-drawn path
/// never quite matches it, and two different hearts for one idea reads as a
/// mistake.
const IconData kHeartIcon = Icons.favorite;

/// Laid-out glyphs, keyed by size, colour and stroke width.
///
/// The pin layer repaints on every frame of a pan, and laying the glyph out
/// each time would be wasted work. The map holds at most a handful of entries:
/// one size, three commitment colours, plus the white outline.
final Map<String, TextPainter> _glyphCache = <String, TextPainter>{};

TextPainter _glyph(double size, Color color, {double? strokeWidth}) {
  final key = '$size|${color.toARGB32()}|${strokeWidth ?? 0}';
  return _glyphCache.putIfAbsent(key, () {
    final style = TextStyle(
      fontSize: size,
      fontFamily: kHeartIcon.fontFamily,
      package: kHeartIcon.fontPackage,
      height: 1,
      color: strokeWidth == null ? color : null,
      foreground: strokeWidth == null
          ? null
          : (Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = color),
    );
    return TextPainter(
      text: TextSpan(
        text: String.fromCharCode(kHeartIcon.codePoint),
        style: style,
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  });
}

/// How far above its text box's centre the glyph's ink actually sits, as a
/// fraction of the font size.
///
/// Measured by rendering the glyph and scanning its alpha: at font size 100 the
/// ink spans y[0..74], so its centre is 13px high of the box's. Centring the
/// box alone leaves the heart riding high inside the selection ring.
const double _inkRise = 0.06;

/// How much of the font size the glyph's ink spans, measured the same way
/// (76 of 100). Lets a caller size a ring that actually fits the heart.
const double kHeartInkRatio = 0.76;

/// Paints [kHeartIcon] centred on [centre], filled with [color] and outlined in
/// [borderColor] so it stays legible against the basemap — the same treatment
/// the circular pins get.
void paintHeart(
  Canvas canvas,
  Offset centre, {
  required double size,
  required Color color,
  required Color borderColor,
  double borderWidth = 2.0,
}) {
  final fill = _glyph(size, color);
  final outline = _glyph(size, borderColor, strokeWidth: borderWidth);
  // Centre the glyph's *ink* on the point, not its text box, so the selection
  // ring drawn around that point is concentric with the heart.
  final origin =
      centre -
      Offset(fill.width / 2, fill.height / 2) +
      Offset(0, size * _inkRise);
  fill.paint(canvas, origin);
  outline.paint(canvas, origin);
}

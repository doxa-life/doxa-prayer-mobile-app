import 'package:flutter/material.dart';

/// A verse number raised above the baseline, welded to the word it introduces.
///
/// Two problems are solved here, both of which Flutter's inline text cannot:
///
///  * **The rise.** [TextStyle] has no baseline shift, and the only in-band
///    spelling — `FontFeature.superscripts()` — is a no-op, because none of
///    the bundled faces implement the OpenType `sups` feature. The number then
///    merely shrinks and stays sitting on the baseline, which reads as a
///    *subscript* next to the larger body text. Painting a smaller [Text]
///    translated upwards is font-independent and gets it right.
///  * **The orphan.** The engine treats a placeholder as a break opportunity
///    whatever surrounds it, so neither a word joiner nor a non-breaking space
///    keeps a lone number attached to its verse. [attached] is therefore drawn
///    inside this widget: one box, which the line breaker can only move whole.
///
/// Meant to be embedded in a [WidgetSpan] aligned on
/// [TextBaseline.alphabetic]. The translation moves only the paint, so the
/// number keeps the baseline and advance width it would have had, and the
/// attached word keeps the surrounding run's metrics exactly.
class SuperscriptText extends StatelessWidget {
  const SuperscriptText({
    super.key,
    required this.text,
    required this.baseStyle,
    this.attached = '',
  });

  /// The raised text — a verse number.
  final String text;

  /// The word that must stay on [text]'s line, drawn at the surrounding size.
  ///
  /// Empty when nothing follows, in which case the gap is left as trailing
  /// padding so the number still clears whatever comes next.
  final String attached;

  /// The style of the surrounding run. Family, colour and slant are inherited;
  /// the size and weight of the number are derived from it.
  final TextStyle baseStyle;

  // ---------------------------------------------------------------------
  // Tuning. All three are multiples of the surrounding font size, so they
  // hold at any text scale. Nudge and hot-reload to taste.
  // ---------------------------------------------------------------------

  /// Size of the number relative to the surrounding text.
  static const double sizeFactor = 0.6;

  /// How far above the baseline to lift it.
  static const double riseFactor = 0.35;

  /// The gap between the number and the word after it.
  ///
  /// This replaces the space the CMS puts inside the mark. A regular space in
  /// this face is about `0.26`, so anything below that tightens it up.
  static const double gapFactor = 0.14;

  /// Used when the surrounding style leaves [TextStyle.fontSize] unset.
  static const double _fallbackFontSize = 14;

  @override
  Widget build(BuildContext context) {
    final fontSize = baseStyle.fontSize ?? _fallbackFontSize;
    // The rise and gap are layout/paint offsets in logical pixels, so unlike
    // the number's font size they are not scaled for us.
    final scaled = MediaQuery.textScalerOf(context).scale(fontSize);

    final number = Transform.translate(
      offset: Offset(0, -scaled * riseFactor),
      child: Text(
        text,
        style: baseStyle.copyWith(
          fontSize: fontSize * sizeFactor,
          fontWeight: FontWeight.w600,
          // Body styles carry generous line height for paragraphs; keeping it
          // here would pad this box and push the line apart.
          height: 1,
        ),
      ),
    );
    final gap = scaled * gapFactor;

    if (attached.isEmpty) {
      // Nothing to weld to, so the gap becomes trailing padding. Directional
      // so it lands on the correct side in Arabic.
      return Padding(
        padding: EdgeInsetsDirectional.only(end: gap),
        child: number,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      // The number is a shorter box than the word; line them up on the
      // baseline rather than centring the two boxes against each other.
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      // baseStyle unmodified, so the word is metrically identical to the run
      // it was lifted out of and the line height does not change.
      children: [
        number,
        SizedBox(width: gap),
        Text(attached, style: baseStyle),
      ],
    );
  }
}

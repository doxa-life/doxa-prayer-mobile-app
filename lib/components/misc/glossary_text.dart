import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../services/glossary.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'hyphenated_text.dart';

/// One of the app's strings, with every glossary term in it tappable to open
/// its definition.
///
/// Where the terms are was worked out when the app was built — see
/// `services/glossary.dart` — so this only looks [data] up; it never searches
/// it. Text the generator never saw (anything from the server) and strings
/// with no term render exactly as [HyphenatedText] would, hyphenation and
/// all. Text with terms trades hyphenation for the links, since a hyphen
/// inserted mid-term would split the tappable span.
///
/// [HyphenatedText] hands its text here whenever it has links, so most
/// strings get them without asking; this widget is for using directly where
/// that isn't wanted to be implicit.
///
/// Stateful only to own its tap recognizers: a [TapGestureRecognizer] built in
/// `build` is never disposed and leaks on every rebuild.
class GlossaryText extends StatefulWidget {
  const GlossaryText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  @override
  State<GlossaryText> createState() => _GlossaryTextState();
}

class _GlossaryTextState extends State<GlossaryText> {
  final List<TapGestureRecognizer> _recognizers = [];

  void _clearRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _clearRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.data;
    final spans = glossarySpansOf(context, text);
    _clearRecognizers();
    if (spans == null || spans.isEmpty) {
      return HyphenatedText(
        text,
        style: widget.style,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
        softWrap: widget.softWrap ?? true,
        glossary: false,
      );
    }
    const linkStyle = TextStyle(
      color: AppColors.secondary,
      decoration: TextDecoration.underline,
      decorationStyle: TextDecorationStyle.dotted,
      decorationColor: AppColors.secondary,
    );
    final children = <TextSpan>[];
    var last = 0;
    for (final span in spans) {
      final term = glossaryTermOf(context, span.termId);
      // The index and the text came from the same ARB file, so this only
      // fails if the index is stale; the words then show unlinked.
      if (term == null || span.start < last || span.end > text.length) {
        continue;
      }
      if (span.start > last) {
        children.add(TextSpan(text: text.substring(last, span.start)));
      }
      final recognizer = TapGestureRecognizer()
        ..onTap = () => showGlossaryDefinition(context, term);
      _recognizers.add(recognizer);
      children.add(
        TextSpan(
          text: text.substring(span.start, span.end),
          style: linkStyle,
          recognizer: recognizer,
        ),
      );
      last = span.end;
    }
    if (last < text.length) children.add(TextSpan(text: text.substring(last)));
    return Text.rich(
      TextSpan(children: children),
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      softWrap: widget.softWrap,
    );
  }
}

/// Shows [term]'s definition in a bottom sheet.
Future<void> showGlossaryDefinition(BuildContext context, GlossaryTerm term) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.md,
          children: [
            Semantics(
              header: true,
              child: HyphenatedText(
                term.term,
                style: AppTypography.h2.copyWith(color: AppColors.primary),
              ),
            ),
            HyphenatedText(
              term.definition,
              softWrap: true,
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      ),
    ),
  );
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/glossary_matcher.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/hyphenated_text.dart';

/// Text in which every glossary term is tappable and opens its definition.
///
/// Terms are found by `GlossaryMatcher`, from the glossary in
/// `services/help_content.dart`, in the app's current language. Text with no
/// terms in it renders exactly as [HyphenatedText] would, hyphenation and all;
/// text with terms trades hyphenation for the links, since a hyphen inserted
/// mid-term would split the tappable span.
///
/// Stateful only to own its tap recognizers: a [TapGestureRecognizer] built in
/// `build` is never disposed and leaks on every rebuild.
class GlossaryText extends StatefulWidget {
  const GlossaryText(this.data, {super.key, this.style, this.textAlign});

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;

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
    final l = AppLocalizations.of(context)!;
    final segments = glossaryMatcherFor(l).split(widget.data);
    _clearRecognizers();
    if (segments.length == 1 && segments.single.term == null) {
      return HyphenatedText(
        widget.data,
        style: widget.style,
        textAlign: widget.textAlign,
        softWrap: true,
      );
    }
    const linkStyle = TextStyle(
      color: AppColors.secondary,
      decoration: TextDecoration.underline,
      decorationStyle: TextDecorationStyle.dotted,
      decorationColor: AppColors.secondary,
    );
    final spans = <TextSpan>[];
    for (final segment in segments) {
      final term = segment.term;
      if (term == null) {
        spans.add(TextSpan(text: segment.text));
        continue;
      }
      final recognizer = TapGestureRecognizer()
        ..onTap = () => showGlossaryDefinition(context, term);
      _recognizers.add(recognizer);
      spans.add(
        TextSpan(text: segment.text, style: linkStyle, recognizer: recognizer),
      );
    }
    return Text.rich(
      TextSpan(children: spans),
      style: widget.style,
      textAlign: widget.textAlign,
    );
  }
}

/// Shows [term]'s definition in a bottom sheet.
Future<void> showGlossaryDefinition(
  BuildContext context,
  ResolvedGlossaryTerm term,
) {
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

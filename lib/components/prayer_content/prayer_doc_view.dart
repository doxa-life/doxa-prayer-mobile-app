import 'package:doxa_prayer_mobile_app/components/misc/titles.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'prayer_verse_view.dart';
import '../misc/hyphenated_text.dart';
import '../misc/superscript_text.dart';

/// Renders a TipTap-style document tree (the `content_json` field on a
/// prayer-content static block).
///
/// Supported block nodes: `paragraph`, `heading`, `verse`, `hardBreak`.
/// Supported inline nodes: `text` (with optional `superscript` mark),
/// `hardBreak`. Unknown node types are skipped silently so that future
/// content additions don't crash older clients.
class PrayerDocView extends StatelessWidget {
  const PrayerDocView({super.key, required this.doc, this.title});

  final Map<String, dynamic> doc;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final nodes = (doc['content'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final widgets = <Widget>[];
    if (title != null) {
      widgets.add(H2(title!, textAlign: TextAlign.start));
    }
    for (final node in nodes) {
      final widget = _renderBlock(node);
      if (widget != null) widgets.add(widget);
    }
    if (widgets.isEmpty) return const SizedBox.shrink();
    widgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          HyphenatedText(
            AppLocalizations.of(context)!.pauseAndPray.toUpperCase(),
            style: AppTypography.caption.copyWith(
              fontSize: AppTypography.md,
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.xxl,
      children: widgets,
    );
  }

  Widget? _renderBlock(Map<String, dynamic> node) {
    switch (node['type']) {
      case 'paragraph':
        return _Paragraph(node: node);
      case 'heading':
        return _Heading(node: node);
      case 'verse':
        return _Verse(node: node);
      case 'hardBreak':
        return const SizedBox(height: AppSpacing.sm);
      default:
        return null;
    }
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph({required this.node});

  final Map<String, dynamic> node;

  @override
  Widget build(BuildContext context) {
    const style = AppTypography.bodyMedium;
    final spans = _inlineSpans(
      node['content'] as List<dynamic>? ?? const [],
      style,
    );
    if (spans.isEmpty) return const SizedBox.shrink();
    return Text.rich(TextSpan(style: style, children: spans));
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.node});

  final Map<String, dynamic> node;

  @override
  Widget build(BuildContext context) {
    final level =
        (node['attrs'] as Map<String, dynamic>?)?['level'] as int? ?? 2;
    final style = level == 1 ? AppTypography.h1 : AppTypography.h2;
    final spans = _inlineSpans(
      node['content'] as List<dynamic>? ?? const [],
      style,
    );
    if (spans.isEmpty) return const SizedBox.shrink();
    return Text.rich(TextSpan(style: style, children: spans));
  }
}

class _Verse extends StatelessWidget {
  const _Verse({required this.node});

  final Map<String, dynamic> node;

  @override
  Widget build(BuildContext context) {
    final attrs = node['attrs'] as Map<String, dynamic>? ?? const {};
    final reference = attrs['reference'] as String? ?? '';
    final translation = attrs['translation'] as String? ?? '';
    final paragraphs = (node['content'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .where((n) => n['type'] == 'paragraph')
        .map(
          (p) => _inlineSpans(
            p['content'] as List<dynamic>? ?? const [],
            PrayerVerseView.textStyle,
          ),
        )
        .where((spans) => spans.isNotEmpty)
        .toList();
    if (paragraphs.isEmpty) return const SizedBox.shrink();
    return PrayerVerseView(
      reference: reference,
      translation: translation,
      paragraphs: paragraphs,
    );
  }
}

/// Flattens TipTap inline nodes into spans drawn on top of [baseStyle], which
/// is the style the enclosing [Text.rich] applies to the whole run.
///
/// Walks with lookahead: a `superscript` node claims the first word of the
/// text node after it, so the two can be drawn as one unbreakable box. See
/// [SuperscriptText] for why that is necessary.
List<InlineSpan> _inlineSpans(List<dynamic> nodes, TextStyle baseStyle) {
  final items = nodes.whereType<Map<String, dynamic>>().toList();
  final out = <InlineSpan>[];
  // Characters at the head of the next text node already drawn by a
  // superscript that claimed them.
  var claimed = 0;

  for (var i = 0; i < items.length; i++) {
    final node = items[i];
    if (node['type'] == 'hardBreak') {
      out.add(const TextSpan(text: '\n'));
      continue;
    }
    if (node['type'] != 'text') continue;

    var text = node['text'] as String? ?? '';
    if (claimed > 0) {
      text = text.substring(claimed);
      claimed = 0;
    }

    // Spans with no marks (and unknown marks) inherit the run's style
    // untouched. A superscript holding nothing but whitespace does too.
    final number = _isSuperscript(node) ? text.trim() : '';
    if (number.isEmpty) {
      if (text.isNotEmpty) out.add(TextSpan(text: text));
      continue;
    }

    // Leading whitespace stays an ordinary span: it separates the number from
    // whatever precedes it, and breaking there is fine.
    final lead = text.substring(0, text.length - text.trimLeft().length);
    if (lead.isNotEmpty) out.add(TextSpan(text: lead));

    final next = i + 1 < items.length ? items[i + 1] : null;
    var word = '';
    if (next != null && next['type'] == 'text' && !_isSuperscript(next)) {
      final (first, consumed) = _firstWord(next['text'] as String? ?? '');
      word = first;
      claimed = consumed;
    }

    out.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: SuperscriptText(
          text: number,
          attached: word,
          baseStyle: baseStyle,
        ),
      ),
    );
  }
  return out;
}

bool _isSuperscript(Map<String, dynamic> node) =>
    (node['marks'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .any((m) => m['type'] == 'superscript');

/// The first word of [text], and how many characters of [text] it covers —
/// including any whitespace before it, which the superscript replaces with its
/// own, tighter gap.
(String, int) _firstWord(String text) {
  final start = text.length - text.trimLeft().length;
  var end = start;
  while (end < text.length && !_isWhitespace(text[end])) {
    end++;
  }
  return (text.substring(start, end), end);
}

bool _isWhitespace(String char) => char.trim().isEmpty;

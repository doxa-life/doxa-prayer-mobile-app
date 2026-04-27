import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'prayer_verse_view.dart';

/// Renders a TipTap-style document tree (the `content_json` field on a
/// prayer-content static block).
///
/// Supported block nodes: `paragraph`, `heading`, `verse`, `hardBreak`.
/// Supported inline nodes: `text` (with optional `superscript` mark),
/// `hardBreak`. Unknown node types are skipped silently so that future
/// content additions don't crash older clients.
class PrayerDocView extends StatelessWidget {
  const PrayerDocView({super.key, required this.doc});

  final Map<String, dynamic> doc;

  @override
  Widget build(BuildContext context) {
    final nodes = (doc['content'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final widgets = <Widget>[];
    for (final node in nodes) {
      final widget = _renderBlock(node);
      if (widget != null) widgets.add(widget);
    }
    if (widgets.isEmpty) return const SizedBox.shrink();
    widgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
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
      spacing: AppSpacing.lg,
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
    final spans = _inlineSpans(node['content'] as List<dynamic>? ?? const []);
    if (spans.isEmpty) return const SizedBox.shrink();
    return Text.rich(
      TextSpan(style: AppTypography.bodyMedium, children: spans),
    );
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
    final spans = _inlineSpans(node['content'] as List<dynamic>? ?? const []);
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
        .map((p) => _inlineSpans(p['content'] as List<dynamic>? ?? const []))
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

List<InlineSpan> _inlineSpans(List<dynamic> nodes) {
  final out = <InlineSpan>[];
  for (final raw in nodes) {
    if (raw is! Map<String, dynamic>) continue;
    switch (raw['type']) {
      case 'text':
        out.add(_textSpan(raw));
        break;
      case 'hardBreak':
        out.add(const TextSpan(text: '\n'));
        break;
    }
  }
  return out;
}

TextSpan _textSpan(Map<String, dynamic> node) {
  final text = node['text'] as String? ?? '';
  final marks = (node['marks'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map((m) => m['type'] as String?)
      .whereType<String>()
      .toSet();

  TextStyle? style;
  if (marks.contains('superscript')) {
    style = const TextStyle(
      fontFeatures: [FontFeature.superscripts()],
      fontWeight: FontWeight.w600,
      fontSize: AppTypography.xs,
    );
  }
  return TextSpan(text: text, style: style);
}
